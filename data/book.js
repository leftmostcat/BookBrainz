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

Book.prototype._insert = function(data, t) {
	var self = this;

	return knex('creator_credit').transacting(t).insert({ pre_phrase: data.pre_phrase }, 'creator_credit_id')
		.then(function(result) {
			data.entity_data.creator_credit_id = result[0];

			return Promise.map(data.credits, function(credit) {
				return knex('creator_credit_name').transacting(t).insert({
					creator_credit_id: result[0],
					position: credit.position,
					creator_id: credit.id,
					name: credit.name,
					join_phrase: credit.join_phrase
				});
			});
		})
		.then(function() {
			return Book.super_.prototype._insert.call(self, data, t);
		});
};

module.exports = Book;
