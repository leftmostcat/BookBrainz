/* vim: set ts=4 sw=4 : */

var knex = require('knex').knex;

function Entity() {}

Entity.prototype._columns = [];
Entity.prototype._table = undefined;
Entity.prototype._joins = [];
Entity.prototype._column_mapping = {};
Entity.prototype._id_column = 'id';

Entity.prototype.get_by_id = function(id) {
	var query = knex(this._table);

	this._joins.forEach(function(join) {
		query = query.join(join.table, join.first, '=', join.second, join.type);
	});

	return query.select(this._columns).where(this._id_column, id);
};

Entity.prototype._insert_with_transaction = function() {};
Entity.prototype.insert = function(data, t) {
	var self = this;

	if (t) {
		return this._insert(data, t);
	}
	else {
		// The calling function didn't give us a transaction, so we make one
		return knex.transaction(function(t) {
			self._insert_with_transaction(data, t)
				.then(t.commit)
				.catch(t.rollback);
		});
	}
};

Entity.prototype.update = function() {};
Entity.prototype.delete = function() {};
Entity.prototype.merge = function() {};

module.exports = Entity;
