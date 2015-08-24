// Generated by CoffeeScript 1.9.3

/**
 * 首页的控制器
 * @author pangjg
 * @date 2015-08-20 21:03:31
 */
var Tools, _, errorRender, main, pageRender;

_ = require('lodash');

Tools = require('../lib/tools');

pageRender = Tools.pageRender;

errorRender = Tools.errorRender;

main = {

  /* 首页 */
  get_index: function(req, res) {
    var _indexDateApi, _listDataApi, pageDatas;
    pageDatas = {};
    _indexDateApi = 'http://pc.api.shenba.com/index.php?act=index&op=index&client=h5';
    _listDataApi = 'http://pc.api.shenba.com/index.php?act=index&op=common&type=101&page=1&client=h5';
    return Tools.getJSON(_indexDateApi, function(flashData) {
      if (flashData.code === '00000') {
        pageDatas.output = flashData.data || {};
        return Tools.getJSON(_listDataApi, function(listDate) {
          if (listDate.code === '00000') {
            pageDatas.output.listdata = listDate.data;
            pageDatas.view = 'index';
            return pageRender(res, pageDatas);
          } else {
            return errorRender(res);
          }
        });
      } else {
        return errorRender(res);
      }
    });
  }
};

module.exports = main;
