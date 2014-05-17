/* vim: ts=4:sw=4 */

function Entity(app) {
	this._columns = undefined;
	this._table = undefined;
	this._column_mapping = {};
	this._id_column = 'id';
	this.sql = app.get('db');
}

Entity.prototype.get_by_id = function(id, callback) {
	this.sql.query('SELECT ' + this._columns +
				' FROM ' + this._table +
				' WHERE ' + this._id_column + ' = $1',
				[ id ], callback);
};

Entity.prototype.insert = function() {};
Entity.prototype.update = function() {};
Entity.prototype.delete = function() {};
Entity.prototype.merge = function() {};

module.exports = Entity;
