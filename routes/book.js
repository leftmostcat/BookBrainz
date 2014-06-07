/* vim: set ts=4 sw=4 : */

var express = require('express');
var router = express.Router();

var auth = require('../lib/auth');
var Book = require('../data/book');

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
	Book.get_by_id(req.params.bbid)
		.then(function(results) {
			res.locals.book = results[0];

			if (!res.locals.book)
				return next();

			res.render('book', {
				title: '“' + res.locals.book.name + '” – BookBrainz',
				user: req.user
			});
		})
		.catch(function(err) {
			return next(err);
		});
});

module.exports = router;
