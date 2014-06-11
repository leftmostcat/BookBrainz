/* vim: set ts=4 sw=4 : */

var express = require('express');
var router = express.Router();

var auth = require('../lib/auth');
var Book = require('../data/book');

router.param('bbid', function(req, res, next, bbid) {
	Book.get_by_id(bbid)
		.then(function(entity) {
			res.locals.entity = entity;
		})
		.exec(next);
});

router.get('/create', auth.isAuthenticated, function(req, res) {
	res.render('book_create', {
		title: 'Add Book – BookBrainz',
		user: req.user
	});
});

router.post('/add', auth.isAuthenticated, function(req, res, next) {
	var data = {
		editor_id: req.user.id,
		pre_phrase: '',
		credits: [{
			position: 0,
			id: req.param('creator_id'),
			name: req.param('creator_name'),
			join_phrase: ''
		}],
		entity_data: {
			name: req.param('title'),
			book_type_id: req.param('book_primary_type_id'),
			comment: req.param('comment')
		}
	};

	Book.insert(data)
		.then(function(result) {
			res.redirect('/book/' + result);
		})
		.catch(function(err) {
			next(err);
		});
});

router.get('/:bbid', function(req, res, next) {
	if (!res.locals.entity)
		return next();

	res.render('book', {
		title: '“' + res.locals.entity.name + '” – BookBrainz',
		user: req.user
	});
});

module.exports = router;
