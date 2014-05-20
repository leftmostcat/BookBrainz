/* vim: ts=4:sw=4 */

var Promise = require('bluebird');
var knex = require('knex').knex;
var util = require('util');

var super_ = require('./coreentity');

function Book() {
	Book.super_.call(this);
}

util.inherits(Book, super_);

Book.prototype._table = 'book';
Book.prototype._id_column = 'book.book_id';
Book.prototype._columns = [
	'book.book_id',
	'book_data.name',
	'book_data.creator_credit_id',
	'book_data.book_type_id',
	'book_data.comment'
];
Book.prototype._joins = [
	{ type: 'left', table: 'book_revision', first: 'book.master_revision_id', second: 'book_revision.revision_id' },
	{ type: 'left', table: 'book_tree', first: 'book_revision.book_tree_id', second: 'book_tree.book_tree_id' },
	{ type: 'left', table: 'book_data', first: 'book_tree.book_data_id', second: 'book_data.book_data_id' }
];

Book.prototype.insert = function(data, callback) {
	knex.transaction(function(t) {
		var revision_id, book_id;

		knex('revision').transacting(t).insert({ editor_id: data.editor_id }, 'revision_id')
			.then(function(result) {
				revision_id = result[0];

				return knex('book').transacting(t).insert({ master_revision_id: revision_id }, 'book_id');
			})
			.then(function(result) {
				book_id = result[0];

				return knex('creator_credit').transacting(t).insert({ pre_phrase: data.pre_phrase }, 'creator_credit_id');
			})
			.then(function(result) {
				return Promise.all([
					knex('book_data').transacting(t).insert({
						name: data.title,
						creator_credit_id: result[0],
						book_type_id: data.book_primary_type_id,
						comment: data.comment
					}, 'book_data_id'),
					Promise.map(data.credits, function(credit) {
						return knex('creator_credit_name').transacting(t).insert({
							creator_credit_id: result[0],
							position: credit.position,
							creator_id: credit.id,
							name: credit.name,
							join_phrase: credit.join_phrase
						});
					})
				]);
			})
			.then(function(result) {
				return knex('book_tree').transacting(t).insert({ book_data_id: result[0][0] }, 'book_tree_id');
			})
			.then(function(result) {
				return knex('book_revision').transacting(t).insert({
					revision_id: revision_id,
					book_id: book_id,
					book_tree_id: result[0]
				});
			})
			.then(function() {
				t.commit(book_id);
			})
			.catch(t.rollback);
	}).exec(callback);
};

module.exports = Book;
