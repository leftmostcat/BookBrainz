/* vim: ts=4:sw=4 */

var express = require('express');
var router = express.Router();

var Book = require('../data/book');

router.get('/create', function(req, res) {
	res.render('book_create', { title: 'Add Book – BookBrainz' });
});

router.post('/add', function(req, res, next) {
	var data = {
		editor_id: 2,
		title: req.param('title'),
		pre_phrase: '',
		credits: [{
			position: 0,
			id: req.param('creator_id'),
			name: req.param('creator_name'),
			join_phrase: ''
		}],
		book_primary_type_id: req.param('book_primary_type_id'),
		comment: req.param('comment')
	};

	var book = new Book(req.app);

	book.insert(data, function(err, book_id) {
		if (err) {
			res.status(500);
			return next(err);
		}

		res.redirect('/book/' + book_id);
	});
});

router.get('/:bbid', function(req, res, next) {
	var book = new Book(req.app);

	book.get_by_uuid(req.params.bbid, function(err, results) {
		if (err) {
			res.status(500);
			return next(err);
		}

		res.locals.book = results[0];

		if (!res.locals.book) {
			res.status(404);
			return next('Not Found');
		}

		res.render('book', { title: '“' + res.locals.book.name + '” – BookBrainz' });
	});
});

module.exports = router;
