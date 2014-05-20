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

Creator.prototype.insert = function(data, callback) {
	knex.transaction(function(t) {
		var revision_id, creator_id;

		knex('revision').transacting(t).insert({ editor_id: data.editor_id }, 'revision_id')
			.then(function(result) {
				revision_id = result[0];

				return knex('creator').transacting(t).insert({ master_revision_id: revision_id }, 'creator_id');
			})
			.then(function(result) {
				creator_id = result[0];

				return knex('creator_data').transacting(t).insert({
					name: data.name,
					sort_name: data.sort_name,
					begin_date_year: data.begin_date_year,
					begin_date_month: data.begin_date_month,
					begin_date_day: data.begin_date_day,
					end_date_year: data.end_date_year,
					end_date_month: data.end_date_month,
					end_date_day: data.end_date_day,
					creator_type_id: data.creator_type_id,
					country_id: data.country_id,
					gender_id: data.gender_id,
					comment: data.comment,
					ended: data.ended
				}, 'creator_data_id');
			})
			.then(function(result) {
				return knex('creator_tree').transacting(t).insert({ creator_data_id: result[0] }, 'creator_tree_id');
			})
			.then(function(result) {
				return knex('creator_revision').transacting(t).insert({
					revision_id: revision_id,
					creator_id: creator_id,
					creator_tree_id: result[0]
				});
			})
			.then(function() {
				t.commit(creator_id);
			})
			.catch(t.rollback);
	}).exec(callback);
};

module.exports = Creator;
