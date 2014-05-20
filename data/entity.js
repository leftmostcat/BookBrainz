/* vim: ts=4:sw=4 */

var knex = require('knex').knex;

function Entity() {}

Entity.prototype._columns = undefined;
Entity.prototype._table = undefined;
Entity.prototype._joins = undefined;
Entity.prototype._column_mapping = {};
Entity.prototype._id_column = 'id';

Entity.prototype.get_by_id = function(id, callback) {
	var query = knex(this._table);

	this._joins.forEach(function(join) {
		query = query.join(join.table, join.first, '=', join.second, join.type);
	});

	query.select(this._columns).where(this._id_column, id)
		.exec(callback);
};

Entity.prototype.insert = function() {};
Entity.prototype.update = function() {};
Entity.prototype.delete = function() {};
Entity.prototype.merge = function() {};

module.exports = Entity;
