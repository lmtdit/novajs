// Generated by CoffeeScript 1.9.3

/**
 * 一些网站的设置
 * @author pjg
 * @date 2015-08-21 18:41:03
 * @version $ID
 */
var Path, _GLOBALVARS, _domain, _domains, _env, _getDomain, _getStaticPath, _staticPath, _staticPaths, config, key, setting, val;

Path = require('path');

config = require('../config.json');

_env = config.env;

_domain = {};

_domains = config.domain;

_getDomain = function(prefix) {
  var tempStr;
  tempStr = "//";
  switch (prefix) {
    case 'global':
      tempStr += _env === 'www' ? "www." + _domains[prefix] : _env + ".pc." + _domains[prefix];
      break;
    case 'img':
      tempStr += _domains[prefix];
      break;
    default:
      tempStr += _env === 'www' ? _domains[prefix] : _env + "." + _domains[prefix];
  }
  return tempStr;
};

for (key in _domains) {
  val = _domains[key];
  _domain[key] = _getDomain(key);
}

_staticPath = _domain['static'] + (_env === 'local' ? "/_src" : "/assets");

_staticPaths = {};


/**
 * 获取静态资源的路径
 * @param  {string} type 类型，包括css,js,img三种
 * @return {string}      静态的URL地址
 */

_getStaticPath = function(type) {
  if (_env === 'local') {
    type = "_" + type;
  }
  return _staticPath + "/" + type;
};

['css', 'js', 'img'].forEach(function(key) {
  return _staticPaths[key] = _getStaticPath(key);
});

_GLOBALVARS = "var STATIC_PATH='" + _staticPath + "',sbLib=window['sbLib']={},_VM_=window['_VM_']={},pcSiteUrl='www.shenba.com',WapSiteUrl='//h5.shenba.com',appDownloadUrl='http://a.app.qq.com/o/simple.jsp?pkgname=com.shenba.market',pagesize='10';";

setting = {
  env: _env,
  secret: config.secret,
  tplPath: config.tpl.path,
  tplMinify: config.tpl.isMinify,
  domains: _domain,
  staticPaths: _staticPaths,
  GLOBALVARS: _GLOBALVARS
};

module.exports = setting;
