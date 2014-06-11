/* vim: set ts=4 sw=4 : */

var _ = require('underscore');

var CoreEntity = require('./coreentity');

var CreatorCredit = require('./creator-credit');

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

	return CreatorCredit.insert(data, t)
		.then(function(result) {
			data.entity_data.creator_credit_id = result;
			return CoreEntity._insert_with_transaction.call(self, data, t);
		});
};

Edition.register();
module.exports = Edition;
