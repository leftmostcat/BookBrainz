/* vim: set ts=4 sw=4 : */

var knex = require('knex').knex;
var util = require('util');

var super_ = require('./entity');

function Editor() {
	Editor.super_.call(this);
}

util.inherits(Editor, super_);

Editor.prototype._table = 'editor';
Editor.prototype._columns = [
	'editor.id',
	'editor.name',
	'editor.email'
];

Editor.prototype.get_by_name = function(name) {
	return knex(this._table).limit(1).select(this._columns).where('name', name);
};

Editor.prototype.insert = function(data) {
	var self = this;

	return knex.transaction(function(t) {
		knex(self._table).transacting(t).insert({
			name: data.name,
			email: data.email
		}, 'id')
			.then(t.commit)
			.catch(t.rollback);
	});
};

module.exports = Editor;
