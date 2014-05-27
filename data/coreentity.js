/* vim: set ts=4 sw=4 : */

var knex = require('knex').knex;
var util = require('util');

var super_ = require('./entity');

function CoreEntity() {
	CoreEntity.super_.call(this);

	this._data_table = this._table + '_data';
	this._tree_table = this._table + '_tree';
	this._revision_table = this._table + '_revision';

	var make_left_join = function(target, source) {
		return {
			type: 'left',
			table: target,
			first: source + '.' + target + '_id',
			second: target + '.' + target + '_id'
		};
	};

	this._joins = [
		{
			type: 'left',
			table: this._revision_table,
			first: this._table + '.master_revision_id',
			second: this._revision_table + '.revision_id'
		},
		make_left_join(this._tree_table, this._revision_table),
		make_left_join(this._data_table, this._tree_table)
	];
}

util.inherits(CoreEntity, super_);

CoreEntity.prototype._build_search_body = function(data) {
	var body = {
		name: data.entity_data.name,
		comment: data.entity_data.comment
	};

	return body;
};

CoreEntity.prototype._insert_with_transaction = function(data, t) {
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

			return knex(self._data_table).transacting(t)
				.insert(data.entity_data, self._data_table + '_id');
		})
		.then(function(result) {
			var data = {};
			data[self._data_table + '_id'] = result[0];

			return knex(self._tree_table).transacting(t)
				.insert(data, self._tree_table + '_id');
		})
		.then(function(result) {
			var data = { revision_id: revision_id };
			data[self._table + '_id'] = entity_id;
			data[self._tree_table + '_id'] = result[0];

			return knex(self._revision_table).transacting(t)
				.insert(data, self._table + '_id');
		});
};

module.exports = CoreEntity;
