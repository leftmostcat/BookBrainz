/* vim: ts=4:sw=4 */

var express = require('express');
var router = express.Router();

var Creator = require('../data/creator');

router.get('/create', function(req, res) {
	res.render('creator_create', { title: 'Add Creator – BookBrainz' });
});

router.post('/add', function(req, res, next) {
	var data = {
		editor_id: 2,
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
	};

	creator = new Creator();

	creator.insert(data, function(err, creator_id) {
		if (err) {
			res.status(500);
			return next(err);
		}

		res.redirect('/creator/' + creator_id);
	});
});

router.get('/:bbid', function(req, res, next) {
	var creator = new Creator();

	creator.get_by_id(req.params.bbid, function(err, results) {
		if (err) {
			res.status(500);
			return next(err);
		}

		res.locals.creator = results[0];

		if (!res.locals.creator) {
			res.status(404);
			return next('Not Found');
		}

		res.render('creator', { title: res.locals.creator.name + ' – BookBrainz' });
	});
});

module.exports = router;
