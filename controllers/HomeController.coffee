###*
 * 首页的控制器
 * @author pangjg
 * @date 2015-08-20 21:03:31
###
module.exports = 
    ### 首页 ###
    get_index: (req, res) ->
        res.send("Index page!")