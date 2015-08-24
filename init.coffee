###*
 * 永不停止的node服务
 * @author pjg
 * @date 2015-08-21 14:47:20
 * @version $ID
###

spawn = require('child_process').spawn
server = null
startServer = ->
    console.log('start server')
    server = spawn('node', ['app.js'])
    console.log('node js pid is ' + server.pid)
    server.on 'close', (code, signal)->
        server.kill(signal)
        server = startServer()
    server.on 'error', (code, signal)->
        server.kill(signal)
        server = startServer()

    return server


startServer()
