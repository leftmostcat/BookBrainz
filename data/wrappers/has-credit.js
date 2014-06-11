/* vim: set ts=4 sw=4 : */

var Promise = require('bluebird'),
	_ = require('underscore');

var CreatorCredit = require('../creator-credit');

var HasCredit = {};

HasCredit.wrap = function(entity) {
	entity.get_by_id = _.wrap(entity.get_by_id, function(fn, id) {
		return fn.call(entity, id)
			.then(function(result) {
				return Promise.all([
					result,
					CreatorCredit.get_by_id(result.creator_credit_id)
				]);
			})
			.then(function(result) {
				var entity = result[0];

				entity.creator_credit = result[1];

				return entity;
			});
	});

	entity._build_search_body = _.wrap(entity._build_search_body, function(fn, data) {
		var body = fn.call(entity, data);

		var creator_credit = data.pre_phrase;

		body.creators = [];

		data.credits.forEach(function(name) {
			creator_credit += name.name + name.join_phrase;

			body.creators.push(name.id);
		});

		body.creator_credit = creator_credit;

		return body;
	});

	entity._insert_with_transaction = _.wrap(entity._insert_with_transaction, function(fn, data, t) {
		var self = this;

		return CreatorCredit.insert(data, t)
			.then(function(result) {
				data.entity_data.creator_credit_id = result;
				return fn.call(self, data, t);
			});
	});
};

module.exports = HasCredit;
