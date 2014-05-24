/* vim: ts=4:sw=4 */

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

Editor.prototype.get_by_name = function(name, callback) {
	knex(this._table).limit(1).select(this._columns).where('name', name)
		.exec(callback);
};

Editor.prototype.insert = function(data, callback) {
	var self = this;

	knex.transaction(function(t) {
		knex(self._table).transacting(t).insert({
			name: data.name,
			email: data.email
		}, 'id')
			.then(function(result) {
				t.commit(result[0]);
			})
			.catch(t.rollback);
	}).exec(callback);
};

module.exports = Editor;
