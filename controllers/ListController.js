module.exports = {
    /* /list.html */
    get_index: function(req, res) {
        res.send("List page test");
    },
    /*post /list */
    post_index: function(req, res) {
        res.send("List page post method test");
    },
    /*/list/:id.html */
    get_id: function(req, res, id) {
        
        res.send("You are requesting the resource with list-id: " + id);
    },
    /* /list/:cid/:bid.html */
    get_cid_bid: function(req, res, cid, bid) {
        res.send("You are requesting the resource with bid: " + bid + "   cid:" + cid);
    },
    /* /list/:cid/:bid/:sid.html */
    get_cid_bid_sid: function(req, res, cid, bid, sid) {
        res.send("People finest subsection test");
    }
}
