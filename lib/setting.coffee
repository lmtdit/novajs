###*
 * 一些网站的设置
 * @author pjg
 * @date 2015-08-21 18:41:03
 * @version $ID
###

Path = require('path')
config = require('../config.json')

_env = config.env
_domain = {}
_domains = config.domain

# 根据环境转换域名
_getDomain = (prefix)->
    tempStr = "//"
    switch prefix
        when 'global'
            tempStr += if _env is 'www' then "www.#{_domains[prefix]}" else "#{_env}.pc.#{_domains[prefix]}"
        when 'img'
            tempStr += _domains[prefix]
        else
            tempStr += if _env is 'www' then _domains[prefix] else "#{_env}.#{_domains[prefix]}"
    return tempStr

# 批量转换域名
for key,val of _domains
    _domain[key] = _getDomain(key)


# 静态资源的路径
_staticPath = _domain['static'] +  (if _env is 'local' then "/_src" else "/assets")
_staticPaths = {}
###*
 * 获取静态资源的路径
 * @param  {string} type 类型，包括css,js,img三种
 * @return {string}      静态的URL地址
###
_getStaticPath = (type)->
    type = "_#{type}" if _env is 'local'
    return "#{_staticPath}/#{type}"
    
['css','js','img'].forEach (key)->
    _staticPaths[key] = _getStaticPath(key)

# 插入到页面中的全局变量
_GLOBALVARS = "var STATIC_PATH='#{_staticPath}',sbLib=window['sbLib']={},_VM_=window['_VM_']={},pcSiteUrl='www.shenba.com',WapSiteUrl='//h5.shenba.com',appDownloadUrl='http://a.app.qq.com/o/simple.jsp?pkgname=com.shenba.market',pagesize='10';"
# 配置
setting = 
    env: _env
    secret: config.secret
    tplPath: config.tpl.path
    tplMinify: config.tpl.isMinify
    domains: _domain
    staticPaths: _staticPaths
    GLOBALVARS: _GLOBALVARS


module.exports = setting