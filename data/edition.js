/* vim: set ts=4 sw=4 : */

var Promise = require('bluebird'),
	_ = require('underscore'),
	knex = require('knex').knex;

var CoreEntity = require('./coreentity');

var Edition = {};
_.extend(Edition, CoreEntity);

Edition._table = 'edition';
Edition._id_column = 'edition.edition_id';
Edition._columns = [
	'edition.edition_id',
	'edition_data.name',
	'edition_data.creator_credit_id',
	'edition_data.edition_status_id',
	'edition_data.country_id',
	'edition_data.language_id',
	'edition_data.script_id',
	'edition_data.date_year',
	'edition_data.date_month',
	'edition_data.date_day',
	'edition_data.barcode',
	'edition_data.comment'
];

Edition._build_search_body = function(data) {
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

Edition._insert_with_transaction = function(data, t) {
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

Edition.register();
module.exports = Edition;
