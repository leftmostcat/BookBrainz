/* vim: set ts=4 sw=4 : */

var Promise = require('bluebird'),
	_ = require('underscore'),
	knex = require('knex').knex;

var CoreEntity = require('./coreentity');

var Book = {};
_.extend(Book, CoreEntity);

Book._table = 'book';
Book._id_column = 'book.book_id';
Book._columns = [
	'book.book_id',
	'book_data.name',
	'book_data.creator_credit_id',
	'book_data.book_type_id',
	'book_data.comment'
];

Book._build_search_body = function(data) {
	var body = CoreEntity._build_search_body.call(this, data);

	var creator_credit = data.pre_phrase;

	body.creators = [];

	data.credits.forEach(function(name) {
		creator_credit += name.name + name.join_phrase;

		body.creators.push(name.id);
	});

	body.creator_credit = creator_credit;

	return body;
};

Book._insert_with_transaction = function(data, t) {
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
			return CoreEntity._insert_with_transaction.call(self, data, t);
		});
};

Book.register();
module.exports = Book;
