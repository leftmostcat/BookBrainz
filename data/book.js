var async = require('async');
var util = require('util');

var super_ = require('./coreentity');

function Book(app) {
	Book.super_.call(this, app);

	this._columns = 'book.book_id, bd.name, bd.creator_credit_id, bd.book_type_id, bd.comment';
	this._table = 'book' +
			' LEFT JOIN book_revision AS br ON book.master_revision_id = br.revision_id AND book.book_id = br.book_id' +
			' LEFT JOIN book_tree AS bt ON br.book_tree_id = bt.book_tree_id' +
			' LEFT JOIN book_data AS bd ON bt.book_data_id = bd.book_data_id';
	this._id_column = 'book.book_id';
}

util.inherits(Book, super_);

Book.prototype.insert = function(data, callback) {
	this.sql.begin(function(err, cursor) {
		cursor.query('INSERT INTO revision(editor_id) VALUES($1) RETURNING revision_id', [ data.editor_id ], function(err, results) {
			var revision_id = results[0].revision_id;

			cursor.query('INSERT INTO book(master_revision_id) VALUES($1) RETURNING book_id', [ revision_id ], function(err, results) {
				var book_id = results[0].book_id;

				cursor.query('INSERT INTO creator_credit(pre_phrase) VALUES($1) RETURNING creator_credit_id', [ data.pre_phrase ], function(err, results) {
					var creator_credit_id = results[0].creator_credit_id;

					async.parallel({
						credits: function(parallelback) {
							async.each(data.credits, function(name, eachback) {
								cursor.query('INSERT INTO creator_credit_name(creator_credit_id, position, creator_id, name, join_phrase)' +
									' VALUES($1, $2, $3, $4, $5)',
									[ creator_credit_id, name.position, name.id, name.name, name.join_phrase ], function(err) {
										eachback(err);
									});
							},
							function(err) {
								parallelback(err);
							});
						},
						book: function(parallelback) {
							cursor.query('INSERT INTO book_data(name, creator_credit_id, book_type_id, comment)' + 
								' VALUES($1, $2, $3, $4) RETURNING book_data_id',
								[ data.title, creator_credit_id, data.book_primary_type_id, data.comment ], function(err, results) {
									if (err)
										return parallelback(err);

									var book_data_id = results[0].book_data_id;

									cursor.query('INSERT INTO book_tree(book_data_id)' +
										' VALUES($1) RETURNING book_tree_id', [ book_data_id ], function(err, results) {
											if (err)
												return parallelback(err);

											var book_tree_id = results[0].book_tree_id;

											cursor.query('INSERT INTO book_revision(revision_id, book_id, book_tree_id)' +
												' VALUES($1, $2, $3)', [ revision_id, book_id, book_tree_id ], function(err) {
													parallelback(err, book_id);
												});
										});
								});
						}
					},
					function(err, results) {
						if (err)
							return callback(err);

						cursor.commit(function(err) {
							callback(err, results.book);
						});
					});
				});
			});
		});
	});
};

module.exports = Book;
