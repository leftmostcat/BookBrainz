/* vim: set ts=4 sw=4 : */

var knex = require('knex').knex;
var search = require('../lib/search');

function Entity() {}

Entity.prototype._columns = [];
Entity.prototype._table = undefined;
Entity.prototype._joins = [];
Entity.prototype._id_column = 'id';

Entity.prototype.get_by_id = function(id) {
	var query = knex(this._table);

	this._joins.forEach(function(join) {
		query = query.join(join.table, join.first, '=', join.second, join.type);
	});

	return query.select(this._columns).where(this._id_column, id);
};

Entity.prototype._build_search_body = undefined;

Entity.prototype._insert_with_transaction = undefined;
Entity.prototype.insert = function(data, t) {
	var self = this;
	var promise;

	if (t) {
		promise = this._insert_with_transaction(data, t);
	}
	else {
		// The calling function didn't give us a transaction, so we make one
		promise = knex.transaction(function(t) {
			self._insert_with_transaction(data, t)
				.then(t.commit)
				.catch(t.rollback);
		});
	}

	return promise.then(function(result) {
		var id = result[0];

		// If indexing behavior is defined for this type, send it to search
		if (self._build_search_body) {
			var body = self._build_search_body(data);

			return search.index(self._table, id, body);
		}

		return id;
	});
};

Entity.prototype.update = function() {};
Entity.prototype.delete = function() {};
Entity.prototype.merge = function() {};

module.exports = Entity;
