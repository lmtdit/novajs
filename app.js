// Generated by CoffeeScript 1.9.3

/**
 * 服务入口 app.js
 * @author pangjg
 * @date 2015-08-20
 */
var Controllers, Path, app, bodyParser, cookieParser, ejs, express, favicon, http, port, router, server, session, setting, viewPath;

Path = require('path');

http = require('http');

express = require('express');

ejs = require('ejs');

session = require('express-session');

favicon = require('static-favicon');

cookieParser = require('cookie-parser');

bodyParser = require('body-parser');

Controllers = require('./lib/controller');

setting = require('./lib/setting');

app = express();

app.use(favicon());

app.use(cookieParser());

app.use(bodyParser());

app.use(bodyParser.json());

app.use(bodyParser.urlencoded());

viewPath = setting.viewPath;

app.set('views', Path.join(__dirname, viewPath));

app.engine('.html', ejs.__express);

app.set('view engine', 'html');

router = express.Router();

app.use(router);

Controllers.setDirectory(__dirname + '/controllers').bind(router);


/**
 * error handler
 */

app.use(function(req, res, next) {
  var err;
  err = new Error('Not Found');
  err.status = 404;
  return next(err);
});

app.use(function(err, req, res, next) {
  res.status(err.status || 500);
  return res.render('error', {
    url: req.originalUrl,
    error: err
  });
});

port = process.env.PORT || 3333;

app.set('port', port);

server = http.createServer(app);

server.listen(app.get('port'), function() {
  return console.log('Express server listening on port ' + app.get('port'));
});