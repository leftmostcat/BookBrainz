/* vim: set ts=4 sw=4 : */

var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res) {
	res.render('index', {
		title: 'BookBrainz – The Open Book Encyclopedia',
		user: req.user
	});
});

module.exports = router;
