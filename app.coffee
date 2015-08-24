###*
 * 服务入口 app.js
 * @author pangjg
 * @date 2015-08-20
###

# BASE SETUP
# ==============================================
Path            = require('path')
http            = require('http')
express         = require('express')
ejs             = require('ejs')
session         = require('express-session')
favicon         = require('static-favicon')
cookieParser    = require('cookie-parser')
bodyParser      = require('body-parser')
# logger          = require('logger')
Controller     = require('./lib/controller')
setting         = require('./lib/setting')

# console.log setting

# 创建express实例
app = express()

# 装载中间件  
app.use(favicon())
app.use(cookieParser())
# app.use(bodyParser())
# app.use(bodyParser.json())
# app.use(bodyParser.urlencoded())
# app.use(logger('dev'))

# 模板引擎设置
app.set('views', Path.join(__dirname, setting.tplPath))
app.engine('.html', ejs.__express)
app.set('view engine', 'html')


# 设置controllers
router = express.Router();
app.use(router)
Controller.setDirectory( __dirname + '/controllers').bind(router)

###*
 * error handler
###
# catch 404
app.use (req, res, next)->
    err = new Error('Not Found')
    err.status = 404
    next(err)
# 输出error页面
app.use (err, req, res, next)->
    res.status err.status || 500
    res.render 'error',
        url: req.originalUrl
        error: err 
        
# ==============================================
# START THE SERVER
port = process.env.PORT || 3333
app.set 'port', port
server = http.createServer(app)
server.listen app.get('port'), ->
    console.log('Express server listening on port ' + app.get('port'))
