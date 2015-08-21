###*
 * 一款给 express 4.x 定制的路由控制器
 * @author pangjg
 * @date 2015-08-20
###

fs = require('fs')

main = 
    setDirectory: (directory)->
        this.directory = directory
        this.pathParams = {}
        this.pathFunctions = {}
        this.pathMiddlewares = {}
        return this
    ###*
     * app事件代理函数
     * @param  {keyValueObject} app = express() ，express的实例
     * @param  {Function} cb  回调函数
    ###
    bind: (app, cb)->
        _app = app
        _this = this
        fs.readdir _this.directory, (err, dirs)->
            if err
                cb and cb(err)
                return false
            dirs.forEach (file)->
                fileName = _this.directory + '/' + file
                if fileName.indexOf('Controller') == -1 or fileName.indexOf('.js') == -1
                    return false
                controller = require(fileName)
                aliases = controller['aliases'] or []
                delete controller['aliases']
                aliases.push(_this.translateFileNameToControllerName(file))
                for key,val of controller
                    # The function in the controller
                    f = val #controller[key]
                    middlewareFunctions = undefined

                    # Array of route middleware support
                    if Array.isArray(f)
                        if f.length == 1
                            f = f[0]
                        else if f.length > 1
                            controllerFunction = f.pop()
                            middlewareFunctions = f
                            f = controllerFunction
                        else
                            throw new Error('控制器未定义')

                    # 获取形参和请求值
                    _params = _this.translateFunctionBodyToParameterArray(f)

                    aliases.forEach (alias) ->
                        _path = _this.translatePath(key, alias, _params)
                        if _path != false 
                            # 代理app访问事件
                            _this.pathMiddlewares[_path.method.toLowerCase() + _path.path] = middlewareFunctions
                            _this.bindFunction(_app, _path, _params, f)
            cb && cb()

    ###*
     * 代理app的访问请求
     * @param  {keyValueObject}  app = express()，express的实例
     * @param  {strings} path   访问路径
     * @param  {object} params  访问形参
     * @param  {Array} f  controller控制器列表数组
    ###
    bindFunction: (app, path, params, f)->
        _this = this
        pathKey = path.method.toLowerCase() + path.path

        _this.pathParams[pathKey] = params
        _this.pathFunctions[pathKey] = f
        if _this.pathMiddlewares[pathKey] && Array.isArray(_this.pathMiddlewares[pathKey])
            app[path.method.toLowerCase()](
                path.path
                _this.pathMiddlewares[pathKey]
                (req, res)->
                    reqKey = req.method.toLowerCase() + req.route.path
                    clonedParams = _this.pathParams[reqKey].slice(0)
                    clonedParams = _this.translateKeysArrayToValuesArray(clonedParams, req.params)
                    clonedParams.unshift(req, res)
                    _this.pathFunctions[reqKey].apply(_this, clonedParams)
            )
        else
            app[path.method.toLowerCase()](
                path.path
                (req, res)->
                    reqKey = req.method.toLowerCase() + req.route.path
                    clonedParams = _this.pathParams[reqKey].slice(0)
                    clonedParams = _this.translateKeysArrayToValuesArray(clonedParams, req.params)
                    clonedParams.unshift(req, res)
                    _this.pathFunctions[reqKey].apply(_this, clonedParams)
            )

    ###*
     * 转换对象数组为数组对象
     * @param  {object} keysArray  URL请求形参构成的数组
     * @param  {Array} keyValueObject  URL请求形参和请求值构成的对象
     * @return {Array} 返回数组
    ###
    translateKeysArrayToValuesArray: (keysArray, keyValueObject)->
        valuesArray = []
        keysArray.forEach (key)->
            valuesArray.push(keyValueObject[key])
        return valuesArray

    ###*
     * 将函数体的形参转换为数组
     * @param  {strings} f 函数体
     * @return {Array}  形参数组
    ###
    translateFunctionBodyToParameterArray: (f)->
        if typeof f == 'function'
            params = f.toString()
                .replace(/((\/\/.*$)|(\/\*[\s\S]*?\*\/)|(\s))/mg, '')
                .match(/^function\s*[^\(]*\(\s*([^\)]*)\)/m)[1]
                .split(/,/)

            if params.length >= 2
                params.splice(0, 2)
                return params
            else 
                throw new Error('控制器缺少参数')
        else
            throw new Error('控制器对象必须是函数')
    ###*
     * 转换文件名为控制器名
     * @param  {strings} fileName 文件名
     * @return {strings} 控制器名
    ###
    translateFileNameToControllerName: (fileName)->
        # console.log(fileName)
        return fileName.slice(0,fileName.lastIndexOf('.'))
            .replace('Controller', '')

    ###*
     * 将访问路径转换为形参对象
     * @param  {strings} methodName     方法名  get or post
     * @param  {strings} controllerName 控制器名
     * @param  {Array} parameters     形参
     * @return {object}           返回一个对象
    ###
    translatePath: (methodName, controllerName, parameters)->
        parameters = parameters or []
        # 控制器名转为小写
        controllerName = controllerName.toLowerCase()

        # 获取方法并转化为小写
        parts = methodName.split('_')
        method = parts[0].toLowerCase()


        #  只允许 'get', 'post', 'put', 'delete' 四种请求方法
        #  如果请求的路径不存在，直接返回
        if ['get', 'post', 'put', 'delete'].indexOf(method) == -1 or parts.length == 0
            return false

        # 构造访问路径
        parts.splice(0, 1)
        path = '/'

        # 如果控制为 'homeController.js' 则为首页
        if controllerName != 'home'
            path += controllerName

        # 构造访问路径
        parts.forEach (part)->
            # 如果 act 名为 index ，则为默认控制器
            # 如果是非首页控制器，默认带上 .html 后缀，优化SEO
            if part == 'index'
                path += `controllerName !== 'home' && method === 'get' ? '.html' : ''`
            else
                separator = `!!~parameters.indexOf(part) ? '/:' : '/'`
                if separator == '/'
                    # 形参路径的字母转换为小写
                    part = part.replace(/([A-Z])/g, '-$1').toLowerCase()
                path += separator + part


        parameters.forEach (parameter)->
            if !~parts.indexOf(parameter)
                path += "/:" + parameter

        # console.log(methodName + '  -->')

        path += `method === 'get' && path.lastIndexOf('/') > '0' ? ".html" : ""`
        obj = 
            path: path
            method: method
        # console.log obj
        return obj

module.exports = main