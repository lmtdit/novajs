module.exports = {
    get_index: function(req, res) {
        res.send("会员中心首页");
    },
    post_index: function(req, res) {
        res.send("获取数据的接口");
    },
    get_userid: function(req, res, userid) {
        res.send("用户信息 " + userid);
    }
}
