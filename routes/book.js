var express = require('express');
var router = express.Router();

var Book = require('../data/book');

router.get('/create', function(req, res) {
	res.render('book_create', { title: 'Add Book – BookBrainz' });
});

router.post('/add', function(req, res) {
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

	book.insert(data, function(err) {
		if (err)
			res.status(500);

		res.redirect('/');
	});
});

module.exports = router;
