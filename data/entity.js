/* vim: set ts=4 sw=4 : */

var knex = require('knex').knex,
	search = require('../lib/search');

var Entity = {};

Entity.register = function() {};

Entity._table = undefined;
Entity._columns = [];
Entity._joins = [];
Entity._id_column = 'id';

Entity.get_by_id = function(id) {
	var query = knex(this._table);

	this._joins.forEach(function(join) {
		query = query.leftJoin(join.table, join.first, join.second);
	});

	return query.first(this._columns).where(this._id_column, id);
};

Entity._build_search_body = function() {
	return {};
};

Entity._insert_with_transaction = function() {};
Entity.insert = function(data, t) {
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

		var body = self._build_search_body(data);

		// If indexing behavior is defined for this type, send it to search
		if (body)
			return search.index(self._table, id, body);
		else
			return id;
	});
};

Entity.update = function() {};
Entity.remove = function() {};
Entity.merge = function() {};

module.exports = Entity;
