/* vim: set ts=4 sw=4 : */

var express = require('express');
var router = express.Router();

var search = require('../lib/search');

router.get('/', function(req, res, next) {
	var type = req.param('type') != 'all' ? req.param('type') : null;

	search.find_by_name(req.param('query'), type)
		.then(function(results) {
			res.locals.results = results;
			res.render('search', { title: 'Search Results – BookBrainz' });
		})
		.catch(function(err) {
			return next(err);
		});
});

module.exports = router;
