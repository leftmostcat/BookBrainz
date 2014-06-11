/* vim: set ts=4 sw=4 : */

var Promise = require('bluebird'),
	_ = require('underscore'),
	knex = require('knex').knex;

var Entity = require('./entity');

var CreatorCredit = {};
_.extend(CreatorCredit, Entity);

CreatorCredit._table = 'creator_credit';
CreatorCredit._columns = [
	'creator_credit.creator_credit_id',
	'creator_credit.pre_phrase'
];
CreatorCredit._id_column = 'creator_credit_id';

CreatorCredit._insert_with_transaction = function(data, t) {
	var self = this;

	return knex(self._table).transacting(t).insert({
		pre_phrase: data.pre_phrase
	}, 'creator_credit_id')
		.tap(function(result) {
			// Add individual credits while still returning the ID
			return Promise.map(data.credits, function(credit) {
				return knex('creator_credit_name').transacting(t).insert({
					creator_credit_id: result[0],
					position: credit.position,
					creator_id: credit.id,
					name: credit.name,
					join_phrase: credit.join_phrase
				});
			});
		});
};

CreatorCredit.register();
module.exports = CreatorCredit;
