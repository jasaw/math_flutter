const WebSocket = require('ws');
var express = require('express');
var app = express();
var http = require('http').Server(app);
// var io = require('socket.io')(http);
var fs = require('fs');
//var path = require('path');
var bodyParser = require('body-parser');
var extend = require('util')._extend;
// var async = require('async');
var os = require('os');
var sqlite3 = require('sqlite3').verbose();
// var formidable = require('formidable');
// var test_db = require('./test-db.js');

//var db = null;
var current_state = 'idle';
var server_config = {
};
var config_file_path = '/home/pi/math_webui/output/math-webui.conf';
var output_top_dir = '/home/pi/math_webui/output';
var database_dir = output_top_dir + '/results-db';
var database_path = database_dir + '/' + os.hostname() + '-math-results.db';


process.on('uncaughtException', function(err) {
  console.log('process.on handler');
  console.log(err);
});

if (global.gc) {
  console.log('Forced garbage collection enabled.')
} else {
  console.log('Pass --expose-gc when launching node to enable forced garbage collection.');
}
restore_config();

app.use(bodyParser.json());

// app.get('/static/:file', function(req, res) {
//   var static_file;
//   static_file = 'static/' + req.params.file;
//   return fs.exists(static_file, function(exists) {
//     var params;
//     if (exists) {
//       return res.sendfile(static_file);
//     } else {
//       res.status(404);
//       return res.render('error', params = {
//         title: 'File error',
//         description: 'File not found'
//       });
//     }
//   });
// });

app.use('/', express.static('build/web'));

app.get('/', function(req, res) {
  res.sendfile(__dirname + '/build/web/index.html');
});

process.on('exit', cleanup);


const wss = new WebSocket.Server({ port: 8888 });
wss.on('connection', (ws) => {
  console.log('Total clients connected : ', wss.clients.length);
  ws.send('Thanks for connecting to this nodejs websocket server');
  var data = {};
  data.type = 'hello';
  data.payload = {'mylist': [1,2,3,4,5]};
  ws.send(JSON.stringify(data));

  ws.on('close', () => {
    console.log('Total clients connected : ', wss.clients.length);
  });

  ws.on('error', console.error);

  ws.on('message', (message) => {
    console.log('[WebSocket] Message was received: ', message);
  });

  // Broadcast aka send messages to all connected clients 
  // ws.on('message', (message) => {
  //   wss.clients.forEach((client) => {
  //     if (client.readyState === WebSocket.OPEN) {
  //       client.send(message); 
  //     }
  //   });
  //   console.log(`[WebSocket] Message ${message} was received`);
  // });
});

// var sockets = {};
// io.on('connection', function(socket) {
//   sockets[socket.id] = socket;
//   console.log("Total clients connected : ", numClients());

//   socket.on('disconnect', function() {
//     delete sockets[socket.id];
//     console.log("Total clients connected : ", numClients());
//   });
//   socket.on('state', function(data) {
//     var rsp_data = {};
//     // TODO: add full questions state to rsp_data
//     emit_state(socket, rsp_data);
//   });
//   socket.on('action', function(data) {
//     if (data.action === 'start') {
//       if (current_state === 'idle') {
//         set_new_state('check_path');
//         var tasks = [test_db.create_dir.bind(null, database_dir),
//                       test_db.connect.bind(null, database_path),
//                       test_db.create_tables.bind(null)];
//         async.series(tasks, function(err, results) {
//           if (err) {
//             console.log('Error: ' + err.message);
//             set_new_state('idle');
//           } else {
//             // TODO: Start math test
//             // start_math_test();
//           }
//         });
//       }
//     } else if (data.action === 'next') {
//     } else if (data.action === 'prev') {
//     } else if (data.action === 'stop') {
//       // TODO: store results in database
//     }
//   });
//   // socket.on('power', function(data) {
//   //   if (data === 'reboot') {
//   //     exec('reboot', function(err, stdout, stderr) {
//   //       if (err)
//   //         console.log('reboot command error: ' + err);
//   //       else {
//   //         io.sockets.emit('power', 'reboot');
//   //         console.log('rebooting...');
//   //       }
//   //     });
//   //   } else if (data === 'shutdown') {
//   //     exec('shutdown -h now', function(err, stdout, stderr) {
//   //       if (err)
//   //         console.log('shutdown command error: ' + err);
//   //       else {
//   //         io.sockets.emit('power', 'shutdown');
//   //         console.log('shutting down...');
//   //       }
//   //     });
//   //   }
//   // });
//   socket.on('diskinfo', function() {
//     emit_diskfree(socket);
//   });
//   // socket.on('files', function(data) {
//   //   if (data === 'ls')
//   //     listFiles(socket);
//   //   else if (data === 'rm')
//   //     deleteFiles();
//   // });
// });


http.listen(80, function() {
  console.log('listening on *:80');
}).on('error', function(err){
  console.log('on error handler');
  console.log(err);
});


function check_file_exists(file, cb) {
  console.log('check: ' + file);
  fs.stat(file, function fsStat(err, stats) {
    if (err) {
      if (err.code === 'ENOENT') {
        return cb(new Error(file + ' does not exist'));
      } else {
        return cb(err);
      }
    }
    if (stats.isFile())
      return cb(null, true);
    return cb(new Error(file + ' is not a file'));
  });
}

function listFiles(socket) {
  fs.readdir(database_dir, function(err, files) {
    if (!err) {
      var f = files.filter(function(file) { return (file.substr(-3) === '.db'); }).sort();
      if (f)
        emit_file_list(f, socket);
    }
  });
  emit_diskfree();
}


function emit_file_list(files, socket) {
  var file_list = {};
  file_list.dir = 'results';
  file_list.files = files;
  if (socket)
    io.to(socket.id).emit('file-list', file_list);
  else
    io.sockets.emit('file-list', file_list);
}


function doDeleteFiles(files, callback) {
  var i = files.length;
  files.forEach(function(filepath) {
    fs.unlink(database_dir + '/' + filepath, function(err) {
      i--;
      if (err) {
        callback(err);
        return;
      } else if (i <= 0) {
        callback(null);
      }
    });
  });
}


function deleteFiles() {
  fs.readdir(database_dir, function(err, files) {
    if (!err) {
      var f = files.filter(function(file) { return (file.substr(-3) === '.db'); });
      if (f) {
        doDeleteFiles(f, function(err) {
            if (err) {
              console.log(err);
            } else {
              emit_file_list([]);
              emit_diskfree();
            }
          });
      }
    }
  });
}


function emit_diskfree(socket) {
  diskfree(output_top_dir, function (error, total, used, free) {
    if (!error) {
      var diskinfo = {};
      diskinfo.total = total;
      diskinfo.used = used;
      diskinfo.free = free;
      if (socket)
        io.to(socket.id).emit('diskinfo', diskinfo);
      else
        io.sockets.emit('diskinfo', diskinfo);
    }
  });
}


function emit_state(socket, additional_data) {
  additional_data = typeof additional_data  !== 'undefined' ?  additional_data  : {};
  var s = {};
  s.state = current_state;
  var data = extend(s, additional_data);
  if (socket)
    io.to(socket.id).emit('state', data);
  else
    io.sockets.emit('state', data);
}


function emit_config(socket) {
  var s = {};
  // TODO: add config items
  if (socket)
    io.to(socket.id).emit('config', s);
  else
    io.sockets.emit('config', s);
}


function set_new_state(new_state, additional_data) {
  current_state = new_state;
  emit_state(null, additional_data);
}


function diskfree(drive, callback) {
  var total = 0;
  var free = 0;
  var used = 0;
  exec("df -k '" + drive.replace(/'/g,"'\\''") + "'", function(error, stdout, stderr) {
    if (error) {
      callback ? callback(error, total, used, free)
      : console.error(stderr);
    } else {
      var lines = stdout.trim().split("\n");
      var str_disk_info = lines[lines.length - 1].replace( /[\s\n\r]+/g,' ');
      var disk_info = str_disk_info.split(' ');
      total = disk_info[1] * 1024;
      used = disk_info[2] * 1024;
      free = disk_info[3] * 1024;
      callback && callback(null, total, used, free);
    }
  });
}


function save_config() {
  var config_file_args = {
  };
  fs.writeFile(config_file_path, JSON.stringify(config_file_args), function (err) {
    if (err) {
      console.log('Failed to save config file ' + config_file_path);
      console.log(err.message);
      return;
    }
    console.log('Configuration saved successfully to ' + config_file_path);
  });
}


function restore_config() {
  try {
    var data = fs.readFileSync(config_file_path);
    var config_file_args = JSON.parse(data);
    console.log('Configuration restored successfully from ' + config_file_path)
  }
  catch (err) {
    console.log('Failed to load config file ' + config_file_path);
    console.log(err);
  }
}


function numClients() {
  return Object.keys(sockets).length;
}


function cleanup() {
  test_db.close_connection();
}
