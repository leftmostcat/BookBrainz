/* vim: set ts=4 sw=4 : */

var _ = require('underscore');

var CoreEntity = require('./core-entity');

var CreatorCredit = require('./creator-credit');

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

Book.get_by_id = function(id) {
	var book = CoreEntity.get_by_id.call(this, id);
	book.creator_credit = CreatorCredit.get_by_id(book.creator_credit_id);

	return book;
};

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

	return CreatorCredit.insert(data, t)
		.then(function(result) {
			data.entity_data.creator_credit_id = result;
			return CoreEntity._insert_with_transaction.call(self, data, t);
		});
};

Book.register();
module.exports = Book;
