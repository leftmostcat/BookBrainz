/* vim: set ts=4 sw=4 : */

var _ = require('underscore'),
	knex = require('knex').knex;

var Entity = require('./entity');

var Editor = {};
_.extend(Editor, Entity);

Editor._table = 'editor';
Editor._columns = [
	'editor.id',
	'editor.name',
	'editor.email'
];

Editor.get_by_name = function(name) {
	return knex(this._table).first(this._columns).where('name', name);
};

Editor._insert_with_transaction = function(data, t) {
	var self = this;

	return knex(self._table).transacting(t).insert({
		name: data.name,
		email: data.email
	}, 'id');
};

Editor.register();
module.exports = Editor;
