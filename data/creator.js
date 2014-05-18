/* vim: ts=4:sw=4 */

var async = require('async');
var util = require('util');

var super_ = require('./coreentity');

function Creator(app) {
	Creator.super_.call(this, app);

	this._columns = 'creator.creator_id, cd.name, cd.sort_name, cd.begin_date_year, cd.begin_date_month, cd.begin_date_day, cd.end_date_year,' +
					' cd.end_date_month, cd.end_date_day, cd.creator_type_id, cd.country_id, cd.gender_id, cd.comment, cd.ended';
	this._table = 'creator' +
				  ' LEFT JOIN creator_revision AS cr ON creator.master_revision_id = cr.revision_id AND creator.creator_id = cr.creator_id' +
				  ' LEFT JOIN creator_tree AS ct ON cr.creator_tree_id = ct.creator_tree_id' +
				  ' LEFT JOIN creator_data AS cd ON ct.creator_data_id = cd.creator_data_id';
	this._id_column = 'creator.creator_id';
}

util.inherits(Creator, super_);

Creator.prototype.insert = function(data, callback) {
	this.sql.begin(function(err, cursor) {
		if (err)
			return callback(err);

		var revision_id, creator_id;

		cursor.query('INSERT INTO revision(editor_id) VALUES($1) RETURNING revision_id', [ data.editor_id ]).then(function(results) {
			revision_id = results[0].revision_id;

			return cursor.query('INSERT INTO creator(master_revision_id) VALUES($1) RETURNING creator_id', [ revision_id ]);
		}).then(function(results) {
			creator_id = results[0].creator_id;

			return cursor.query('INSERT INTO creator_data(name, sort_name, begin_date_year, begin_date_month,' +
								' begin_date_day, end_date_year, end_date_month, end_date_day, creator_type_id,' +
								' country_id, gender_id, comment, ended) VALUES($1, $2, $3, $4, $5, $6, $7, $8,' +
								' $9, $10, $11, $12, $13) RETURNING creator_data_id',
								[ data.name, data.sort_name, data.begin_date_year, data.begin_date_month, data.begin_date_day,
								  data.end_date_year, data.end_date_month, data.end_date_day, data.creator_type_id,
								  data.country_id, data.gender_id, data.comment, data.ended ]);
		}).then(function(results) {
			var creator_data_id = results[0].creator_data_id;

			return cursor.query('INSERT INTO creator_tree(creator_data_id) VALUES($1) RETURNING creator_tree_id', [ creator_data_id ]);
		}).then(function(results) {
			var creator_tree_id = results[0].creator_tree_id;

			return cursor.query('INSERT INTO creator_revision(revision_id, creator_id, creator_tree_id)' +
								' VALUES($1, $2, $3)', [ revision_id, creator_id, creator_tree_id ]);
		}).then(function() {
			return cursor.commit();
		}).done(
			function() {
				callback(undefined, creator_id);
			},
			function(err) {
				callback(err);
			}
		);
	});
};

module.exports = Creator;
