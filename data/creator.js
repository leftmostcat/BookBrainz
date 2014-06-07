/* vim: set ts=4 sw=4 : */

var _ = require('underscore');

var CoreEntity = require('./coreentity');

var Creator = {};
_.extend(Creator, CoreEntity);

Creator._table = 'creator';
Creator._id_column = 'creator.creator_id';
Creator._columns = [
	'creator.creator_id',
	'creator_data.name',
	'creator_data.sort_name',
	'creator_data.begin_date_year',
	'creator_data.begin_date_month',
	'creator_data.begin_date_day',
	'creator_data.end_date_year',
	'creator_data.end_date_month',
	'creator_data.end_date_day',
	'creator_data.creator_type_id',
	'creator_data.country_id',
	'creator_data.gender_id',
	'creator_data.comment',
	'creator_data.ended'
];

Creator.register();
module.exports = Creator;
