/* vim: set ts=4 sw=4 : */

var _ = require('underscore');

var CoreEntity = require('./core-entity');

var HasCredit = require('./wrappers/has-credit');

var Edition = {};
_.extend(Edition, CoreEntity);

HasCredit.wrap(Edition);

Edition._table = 'edition';
Edition._id_column = 'edition.edition_id';
Edition._columns = [
	'edition.edition_id',
	'edition_data.name',
	'edition_data.creator_credit_id',
	'edition_data.book_id',
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

Edition.register();
module.exports = Edition;
