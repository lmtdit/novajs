// Generated by CoffeeScript 1.9.3

/**
 * 永不停止的node服务
 * @author pjg
 * @date 2015-08-21 14:47:20
 * @version $ID
 */
var server, spawn, startServer;

spawn = require('child_process').spawn;

server = null;

startServer = function() {
  console.log('start server');
  server = spawn('node', ['app.js']);
  console.log('node js pid is ' + server.pid);
  server.on('close', function(code, signal) {
    server.kill(signal);
    return server = startServer();
  });
  server.on('error', function(code, signal) {
    server.kill(signal);
    return server = startServer();
  });
  return server;
};

startServer();
