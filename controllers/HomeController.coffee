###*
 * 首页的控制器
 * @author pangjg
 * @date 2015-08-20 21:03:31
###

_           = require('lodash')
Tools       = require('../lib/tools')
# setting     = require('../lib/setting')

pageRender = Tools.pageRender
errorRender = Tools.errorRender
main = 
    ### 首页 ###
    get_index: (req, res) ->
        pageDatas = {}
        _indexDateApi = 'http://pc.api.shenba.com/index.php?act=index&op=index&client=h5'
        _listDataApi = 'http://pc.api.shenba.com/index.php?act=index&op=common&type=101&page=1&client=h5'
        Tools.getJSON(
            _indexDateApi
            (flashData)->
                if flashData.code is '00000'
                    pageDatas.output = flashData.data or {}
                    Tools.getJSON(
                        _listDataApi
                        (listDate)->
                            # console.log listDate
                            if listDate.code is '00000'
                                pageDatas.output.listdata = listDate.data
                                pageDatas.view = 'index'
                                pageRender(res,pageDatas)
                            else
                                errorRender(res)
                    )
                else
                    errorRender(res)
        )
            

module.exports = main