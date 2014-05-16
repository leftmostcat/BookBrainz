var async = require('async');
var util = require('util');

var super_ = require('./entity');

function Book(app) {
	this._columns = undefined;
	this._table = undefined;
	this._column_mapping = {};
	this._id_column = 'id';
	this.sql = app.get('db');

	Book.super_.call(this, app);
}

util.inherits(Book, super_);

Book.prototype.insert = function(data, callback) {
	this.sql.begin(function(err, cursor) {
		cursor.query('INSERT INTO revision(editor_id) VALUES($1) RETURNING revision_id', [ data.editor_id ], function(err, results) {
			var revision_id = results[0].revision_id;

			cursor.query('INSERT INTO book(master_revision_id) VALUES($1) RETURNING book_id', [ revision_id ], function(err, results) {
				var book_id = results[0].book_id;
				console.log(book_id);

				cursor.query('INSERT INTO creator_credit(pre_phrase) VALUES($1) RETURNING creator_credit_id', [ data.pre_phrase ], function(err, results) {
					var creator_credit_id = results[0].creator_credit_id;

					async.parallel([
						function(parallelback) {
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
						function(parallelback) {
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
													parallelback(err);
												});
										});
								});
						}
					],
					function(err) {
						if (err)
							return callback(err);

						cursor.commit(function(err) {
							callback(err);
						});
					});
				});
			});
		});
	});
};

module.exports = Book;
