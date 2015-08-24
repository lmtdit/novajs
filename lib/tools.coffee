###*
* Basic tools
* @date 2014-12-2 15:10:14
* @author pjg <iampjg@gmail.com>
* @link http://pjg.pw
* @version $Id$
###

fs       = require('fs')
path     = require('path')
_url     = require("url")
http     = require('http')
https    = require('https')
Buffer   = require('buffer').Buffer
queryStr = require('querystring')
crypto   = require('crypto')
_        = require('lodash')
setting  = require('./setting')



_env     = setting.env
_jsPath  = setting.staticPaths.js
_cssPath = setting.staticPaths.css
_imgPath = setting.staticPaths.img

# 一个默认的加密解密私钥
key = "%#12ds)*(shenba_2015"
Tools = {} 
# md5 hash
Tools.md5 = (source) ->
    # 使用二进制转换，解决中文摘要计算不准的问题
    _buf = new Buffer(source)
    _str = _buf.toString "binary"
    crypto.createHash('md5').update(_str).digest('hex')


###*
* make dir
###
Tools.mkdirsSync = (dirpath, mode)->
    if fs.existsSync(dirpath)
        return true
    else
        if Tools.mkdirsSync path.dirname(dirpath), mode
            fs.mkdirSync(dirpath, mode)
            return true
###*
* make dirs
###
Tools.mkdirs = (dirpath, mode, callback)->
    fs.exists dirpath,(exists)->
        if exists
            callback(exists)
        else
            # Try made the parent's dir，then make the current dir
            Tools.mkdirs path.dirname(dirpath), mode, ->
                fs.mkdir dirpath, mode, callback
###*
 * obj mixin function
 * Example:
 * food = { 'key': 'apple' }
 * food2 = { 'name': 'banana', 'type': 'fruit' }
 * console.log objMixin(food2,food)
 * console.log objMixin(food,food2)
###
Tools.objMixin = _.partialRight _.assign, (a, b) ->
    val = if (typeof a is 'undefined') then b else a
    return val
    
# 获取文件
Tools.getFileSync = (file, encoding)->
    _encoding = encoding or 'utf8'
    fileCon = ''
    if fs.existsSync(file)
        stats = fs.statSync(file)
        if stats.isFile()
            fileCon = fs.readFileSync(file, _encoding)
    return fileCon

# 获取文件json对象
Tools.getJSONSync = (file) ->
    string = fs.readFileSync(file,'utf8')
    return JSON.parse(string,true)

# 发送get请求
Tools.getUrl = (url, callback, errback)->
    resultData = ''
    option = _url.parse(url)
    HttpType = if option.protocol.indexOf('https') > -1 then https else http
    HttpType.get url,(res)->
        res.setEncoding('utf8')
        res.on 'data',(data)->
            resultData += data
        res.on 'end',->
            callback && callback(resultData);          
    .on 'error',(e)->
        errback && errback(e.message)

# 发送post请求
Tools.postUrl = (url, data, headers, callback, errback)->
    resultData = ''
    option = _url.parse(url)
    sendData = if _.isObject(data) then queryStr.stringify(data) else data
    option.method = 'POST'
    option.headers = 
        "Content-Type": 'application/x-www-form-urlencoded' 
        "Content-Length": sendData.length 

    if headers
        option.headers = _.assign(option.headers, headers)
    
    HttpType = if option.protocol is 'http:' then http else https

    req = HttpType.request option, (res) ->
        res.setEncoding('utf8');
        res.on 'data', (data)->
            resultData += data;
        res.on 'end',->
            callback and callback(resultData)     

    req.on 'error',(e)->
        errback and errback(e.message)
    req.write sendData + "\n"
    req.end()

# 获取远程json对象
Tools.getJSON = (url, callback, errback)->
    Tools.getUrl url, (data)->
        json = null
        try
            json = JSON.parse(data)
        catch e
            #console.log(e)
            errback and errback(e)
            return false
        
        callback and callback(json)
    , errback

# 递归执行代码
# deepFunc : 单项值、回调
# cumulateFunc : 单项结果，单项值、deep
Tools.deepDo = (list, deepFunc, cumulateFunc, callback, deep)->
    deep = deep or 0
    if not list[deep]
        callback() if callback
        return
    
    deepFunc list[deep], (result)->
        if cumulateFunc
            cumulateFunc(result, list[deep], deep)
        # 递归
        if deep + 1 < list.length
            Tools.deepDo(list, deepFunc, cumulateFunc, callback, deep + 1)
        else 
            callback and callback()

# 执行命令
Tools.exec = (command, callback)->
    exec command,(error, stdout, stderr)->
        # console.log(command + ' 执行中...')
        if stdout
            console.log('exec stdout: ' + stdout)
        if stderr
            console.log('exec stderr: ' + stderr)
        if error
            console.log('exec error: ' + error)
        # console.log(command + ' 执行完毕！')
        callback() if callback


# crypto加密
Tools.enCrypto = (str, secret)->
    _secret = secret or key
    cipher = crypto.createCipher('aes192', _secret)
    enc = cipher.update(str, 'utf8', 'hex')
    enc += cipher.final('hex')
    return enc

# crypto解密
Tools.deCrypto = (str, secret)->
    _secret = secret or key
    decipher = crypto.createDecipher('aes192', _secret)
    dec = decipher.update(str, 'hex', 'utf8')
    dec += decipher.final('utf8')
    return dec

###*
 * 获取js/css/img的map
 * @type {srting}  css or js or img
###
Tools.getMap = (type)->
    _map = {}
    _mapName = 
        switch type
            when 'js' then 'jslibs.json'
            when 'css' then 'cssmap.json'
            when 'img' then 'cssbgmap.json'
    _mapPath = path.join(__dirname,'..','map',_mapName)
    try
        _map = Tools.getJSONSync(_mapPath)
    catch e
        console.log e
    return _map

 
# 获取css和js静态资源的map
Tools.getStaticMaps = ->
    return Tools.objMixin Tools.getMap('css'),Tools.getMap('js')
    
###*
 * 构造 css 资源路径
 * @param {string} cssList css列表
 * @example
 * cssList = 'main.css,index.css'
###
Tools.init_css = (cssList)->
    _cssLinks = ''
    _cssMap = Tools.getMap('css')
    _arr = cssList.split(',')
    _timestamp = String(new Date().getTime()).substr(0,8)
    _arr.forEach (key)->
        val = if _env isnt 'local' and _.has(_cssMap,key) then _cssMap[key].distname else "#{key}?t=#{_timestamp}"
        _cssLinks += "<link href='#{_cssPath}/#{val}' rel='stylesheet' type='text/css' />"
    return _cssLinks + "<script>#{setting.GLOBALVARS}</script>"

###*
 * 构造 js 资源路径
 * @param {string} jsList js列表
 * @example
 * jsList = 'sb.corelibs.js,sb.app_index.js,piwik.js'
###
Tools.init_js = (jsList)->
    _jsLinks = ""
    _jsMap = Tools.getMap('js')
    _arr = jsList.split(',')
    _timestamp = String(new Date().getTime()).substr(0,8)
    _reqJs = "<script src='#{_jsPath}/vendor/require/require.js?v=2.5'></script>"    
    _reqJs += "<script src='#{_jsPath}/vendor/Zepto/zepto.js?v=2.5'></script>"
    _reqJs += "<script src='#{_jsPath}/require_cfg.js?t=#{_timestamp}'></script>"
    _jsLinks = _reqJs if _env is 'local'
    _arr.forEach (key)->
        if _env is 'local'
            if key.indexOf('sb.') isnt 0
                val = "#{key}?t=#{_timestamp}"
                _jsLinks += "<script src='#{_jsPath}/#{val}'></script>"
            else
                _modName = key.replace('sb.','')
                     .replace('.js','')
                     .replace(/\_/g,'/')
                key isnt 'sb.corelibs.js' and _jsLinks += "<script>require(['#{_modName}'])</script>"
        else
            val = if _.has(_jsMap,key) then _jsMap[key].distname else "#{key}?t=#{_timestamp}"
            _jsLinks += "<script src='#{_jsPath}/#{val}'></script>"

    return _jsLinks

# 构造 img 资源路径
Tools.init_img = (imgName)->
    _imgMap = Tools.getMap('img')
    _timestamp = String(new Date().getTime()).substr(0,8)
    _val = if _env isnt 'local' and _.has(_imgMap,imgName) then _imgMap[imgName].distname else "#{imgName}?t=#{_timestamp}"
    return "#{_imgPath}/#{_val}"

     

# 重写 app 的 res 函数，带上一些全局参数
Tools.pageRender = (res, data, tpl)->
    data = data or {}
    tpl and data.view = tpl
    data.env = _env
    data.domains = setting.domains
    data.staticPaths = setting.staticPaths
    data.init_css = Tools.init_css
    data.init_js = Tools.init_js
    data.init_img = Tools.init_img
    res.render and res.render(data.view, data)

# API回调错误的页面渲染处理函数
Tools.errorRender = (res, data)->
    data = data or {}
    data.view = 'error'
    data.url = req.originalUrl
    data.error = 
        message: _flashData.desc
        status: _flashData.code
    res.render and res.render(data.view, data)

module.exports = Tools