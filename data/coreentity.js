/* vim: ts=4:sw=4 */

var knex = require('knex').knex;
var util = require('util');

var super_ = require('./entity');

function CoreEntity() {
	CoreEntity.super_.call(this);

	this._joins = [
		{
			type: 'left',
			table: this._table + '_revision',
			first: this._table + '.master_revision_id',
			second: this._table + '_revision.revision_id'
		},
		{
			type: 'left',
			table: this._table + '_tree',
			first: this._table + '_revision.' + this._table + '_tree_id',
			second: this._table + '_tree.' + this._table + '_tree_id'
		},
		{
			type: 'left',
			table: this._table + '_data',
			first: this._table + '_tree.' + this._table + '_data_id',
			second: this._table + '_data.' + this._table + '_data_id'
		}
	];
}

util.inherits(CoreEntity, super_);

CoreEntity.prototype._insert = function(data, t) {
	var self = this;
	var revision_id, entity_id;

	return knex('revision').transacting(t)
		.insert({ editor_id: data.editor_id }, 'revision_id')
		.then(function(result) {
			revision_id = result[0];

			return knex(self._table).transacting(t)
				.insert({ master_revision_id: revision_id }, self._table + '_id');
		})
		.then(function(result) {
			entity_id = result[0];

			return knex(self._table + '_data').transacting(t)
				.insert(data.entity_data, self._table + '_data_id');
		})
		.then(function(result) {
			var data = {};
			data[self._table + '_data_id'] = result[0];

			return knex(self._table + '_tree').transacting(t)
				.insert(data, self._table + '_tree_id');
		})
		.then(function(result) {
			var data = { revision_id: revision_id };
			data[self._table + '_id'] = entity_id;
			data[self._table + '_tree_id'] = result[0];

			return knex(self._table + '_revision').transacting(t)
				.insert(data, self._table + '_id');
		});
};

module.exports = CoreEntity;
