/* vim: ts=4:sw=4 */

var async = require('async');
var q = require('q');
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
		if (err)
			return callback(err);

		var revision_id, book_id;

		cursor.query('INSERT INTO revision(editor_id) VALUES($1) RETURNING revision_id', [ data.editor_id ]).then(function(results) {
			revision_id = results[0].revision_id;

			return cursor.query('INSERT INTO book(master_revision_id) VALUES($1) RETURNING book_id', [ revision_id ]);
		}).then(function(results) {
			book_id = results[0].book_id;

			return cursor.query('INSERT INTO creator_credit(pre_phrase) VALUES($1) RETURNING creator_credit_id', [ data.pre_phrase ]);
		}).then(function(results) {
			var deferred = q.defer();
			var creator_credit_id = results[0].creator_credit_id;

			async.parallel([
				function(callback) {
					async.each(data.credits, function(name, callback) {
						cursor.query('INSERT INTO creator_credit_name(creator_credit_id, position, creator_id, name, join_phrase)' +
									 ' VALUES($1, $2, $3, $4, $5)',
									 [ creator_credit_id, name.position, name.id, name.name, name.join_phrase ]).done(
							function() {
								callback();
							},
							function(err) {
								callback(err);
							}
						);
					},
					function(err) {
						callback(err);
					});
				},
				function(callback) {
					cursor.query('INSERT INTO book_data(name, creator_credit_id, book_type_id, comment)' + 
								 ' VALUES($1, $2, $3, $4) RETURNING book_data_id',
								 [ data.title, creator_credit_id, data.book_primary_type_id, data.comment ]).then(function(results) {
						var book_data_id = results[0].book_data_id;

						return cursor.query('INSERT INTO book_tree(book_data_id)' +
											' VALUES($1) RETURNING book_tree_id', [ book_data_id ]);
					}).then(function(results) {
						var book_tree_id = results[0].book_tree_id;

						return cursor.query('INSERT INTO book_revision(revision_id, book_id, book_tree_id)' +
											' VALUES($1, $2, $3)', [ revision_id, book_id, book_tree_id ]);
					}).done(
						function() {
							callback();
						},
						function(err) {
							callback(err);
						}
					);
				},
			],
			function(err) {
				if (err)
					return deferred.reject(err);

				deferred.resolve();
			});

			return deferred.promise;
		}).then(function() {
			return cursor.commit();
		}).done(
			function() {
				callback(undefined, book_id);
			},
			function(err) {
				callback(err);
			}
		);
	});
};

module.exports = Book;
