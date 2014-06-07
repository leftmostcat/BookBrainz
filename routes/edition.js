/* vim: set ts=4 sw=4 : */

var express = require('express');
var router = express.Router();

var auth = require('../lib/auth');
var Edition = require('../data/edition');

router.get('/create', auth.isAuthenticated, function(req, res) {
	res.render('edition_create', { title: 'Add Edition – BookBrainz' });
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

	Edition.insert(data)
		.then(function(result) {
			res.redirect('/edition/' + result);
		})
		.catch(function(err) {
			next(err);
		});
});

router.get('/:bbid', function(req, res, next) {
	Edition.get_by_id(req.params.bbid)
		.then(function(results) {
			res.locals.edition = results[0];

			if (!res.locals.edition)
				return next();

			res.render('edition', { title: '“' + res.locals.edition.name + '” – BookBrainz' });
		})
		.catch(function(err) {
			return next(err);
		});
});

module.exports = router;
