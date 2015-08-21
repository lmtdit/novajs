module.exports = {
    /* /detail.html */
    get_index: function(req, res) {
        res.send("Detail index page test");
    },
    /* post /detail */
    post_index: function(req, res) {
        res.send("Detail index page post method test");
    },
    /* /detail/:id.html */
    get_id: function(req, res, id) {
        res.send("You are requesting the resource with id: " + id);
    }
}
