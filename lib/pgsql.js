var pg = require('pg');

var connect = 'pg://bookbrainz:bookbrainz@localhost:5432/bookbrainz';

function pgsql() {}

var rollback = function(client, done) {
	client.query('ROLLBACK', function(err) {
		return done(err);
	});
};

function Cursor(client, done) {
	this._client = client;
	this._done = done;
}

Cursor.prototype.query = function(query, params, callback) {
	var cursor = this;

	this._client.query(query, params, function(err, results) {
		if (err) {
			console.log(query);
			console.log(err);
			rollback(cursor._client, cursor._done);
			return callback(err);
		}

		callback(err, results.rows);
	});
};

Cursor.prototype.commit = function(callback) {
	var cursor = this;

	this._client.query('COMMIT', function(err) {
		if (err) {
			console.log(err);
			rollback(this._client, this._done);
			return callback(err);
		}

		cursor._done();
		callback(err);
	});
};

pgsql.prototype.begin = function(callback) {
	pg.connect(connect, function(err, client, done) {
		if (err) {
			console.log(err);
			done(err);
			return callback(err);
		}

		client.query('BEGIN', function(err) {
			if (err) {
				console.log(err);
				return rollback(client, done);
			}

			callback(err, new Cursor(client, done));
		});
	});
};

pgsql.prototype.query = function(query, params, callback) {
	pg.connect(connect, function(err, client, done) {
		if (err) {
			console.log(err);
			done(err);
			return callback(err);
		}

		client.query(query, params, function(err, results) {
			if (err) {
				console.log(err);
				done(err);
				return callback(err);
			}

			done();
			callback(err, results.rows);
		});
	});
};

module.exports = pgsql;
