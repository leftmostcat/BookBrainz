/* vim: set ts=4 sw=4 : */

var express = require('express');
var router = express.Router();

var auth = require('../lib/auth');
var Creator = require('../data/creator');

router.get('/create', auth.isAuthenticated, function(req, res) {
	res.render('creator_create', { title: 'Add Creator – BookBrainz' });
});

router.post('/add', auth.isAuthenticated, function(req, res, next) {
	var data = {
		editor_id: req.user.id,
		entity_data: {
			name: req.param('name'),
			sort_name: req.param('sort_name'),
			begin_date_year: undefined,
			begin_date_month: undefined,
			begin_date_day: undefined,
			end_date_year: undefined,
			end_date_month: undefined,
			end_date_day: undefined,
			creator_type_id: req.param('creator_type_id'),
			country_id: req.param('country_id'),
			gender_id: req.param('gender_id'),
			comment: req.param('comment'),
			ended: req.param('ended') ? req.param('ended') : false
		}
	};

	var creator = new Creator();

	creator.insert(data)
		.then(function(result) {
			res.redirect('/creator/' + result[0]);
		})
		.catch(function(err) {
			res.status(500);
			next(err);
		});
});

router.get('/:bbid', function(req, res, next) {
	var creator = new Creator();

	creator.get_by_id(req.params.bbid)
		.then(function(results) {
			res.locals.creator = results[0];

			if (!res.locals.creator) {
				res.status(404);
				return next('Not Found');
			}

			res.render('creator', { title: res.locals.creator.name + ' – BookBrainz' });
		})
		.catch(function(err) {
			res.status(500);
			return next(err);
		});
});

module.exports = router;
