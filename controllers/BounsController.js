module.exports = {
    /* /bouns.html */
    get_index: function(req, res) {
        res.send("红包分享页面");
    },
    post_index: function(req, res) {
        res.send("获取红包的接口");
    },
    /* /bouns/:id.html */
    get_id: function(req, res, id) {
        res.send("领域红包，资格ID为: " + id);
    }
}
