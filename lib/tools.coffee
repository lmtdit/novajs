###*
* Basic tools
* @date 2014-12-2 15:10:14
* @author pjg <iampjg@gmail.com>
* @link http://pjg.pw
* @version $Id$
###

fs      = require 'fs'
path    = require 'path'
_url    = require "url"
http    = require "http"
https   = require "https"
queryStr = require "querystring"
crypto  = require "crypto"
_       = require "lodash"
Tools   = {}

# base64  = require "./base64"

#一个加密解密的key
key = "%#12ds)*(shenba_2015"

# md5 hash
Tools.md5 = (text)->
    crypto.createHash('md5').update(text).digest('hex')

###
# make dir
###
Tools.mkdirsSync = (dirpath, mode)->
    if fs.existsSync(dirpath)
        return true
    else
        if Tools.mkdirsSync path.dirname(dirpath), mode
            fs.mkdirSync(dirpath, mode)
            return true
###
# make dirs
###
Tools.mkdirs = (dirpath, mode, callback)->
    fs.exists dirpath,(exists)->
        if exists
            callback(exists)
        else
            # Try made the parent's dir，then make the current dir
            mkdirs path.dirname(dirpath), mode, ->
                fs.mkdir dirpath, mode, callback

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
# deepFunc: 单项值、回调
# cumulateFunc: 单项结果，单项值、deep
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
            callback() if callback

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
Tools.encrypt = (str, secret)->
    _secret = secret or key
    cipher = crypto.createCipher('aes192', _secret)
    enc = cipher.update(str, 'utf8', 'hex')
    enc += cipher.final('hex')
    return enc

# crypto解密
Tools.decrypt = (str, secret)->
    _secret = secret or key
    decipher = crypto.createDecipher('aes192', _secret)
    dec = decipher.update(str, 'hex', 'utf8')
    dec += decipher.final('utf8')
    return dec

# base64加密解密
# Tools.encode = base64.encode
# Tools.decode = base64.decode

module.exports = Tools