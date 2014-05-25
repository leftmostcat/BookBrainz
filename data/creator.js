/* vim: ts=4:sw=4 */

var knex = require('knex').knex;
var util = require('util');

var super_ = require('./coreentity');

function Creator() {
	Creator.super_.call(this);
}

util.inherits(Creator, super_);

Creator.prototype._table = 'creator';
Creator.prototype._id_column = 'creator.creator_id';
Creator.prototype._columns = [
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
Creator.prototype._joins = [
	{ type: 'left', table: 'creator_revision', first: 'creator.master_revision_id', second: 'creator_revision.revision_id' },
	{ type: 'left', table: 'creator_tree', first: 'creator_revision.creator_tree_id', second: 'creator_tree.creator_tree_id' },
	{ type: 'left', table: 'creator_data', first: 'creator_tree.creator_data_id', second: 'creator_data.creator_data_id' }
];

module.exports = Creator;
