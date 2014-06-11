/* vim: set ts=4 sw=4 : */

var _ = require('underscore');

var CoreEntity = require('./core-entity');

var HasCredit = require('./wrappers/has-credit');

var Book = {};
_.extend(Book, CoreEntity);

HasCredit.wrap(Book);

Book._table = 'book';
Book._id_column = 'book.book_id';
Book._columns = [
	'book.book_id',
	'book_data.name',
	'book_data.creator_credit_id',
	'book_data.book_type_id',
	'book_data.comment'
];

Book.register();
module.exports = Book;
