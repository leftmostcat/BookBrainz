/* vim: set ts=4 sw=4 : */

var elasticsearch = require('elasticsearch');

var client = undefined;

var search = {
	init: function() {
		client = new elasticsearch.Client({
			host: 'localhost:9200'
		});
	},
	index: function(type, id, body) {
		return client.index({
			index: 'bookbrainz',
			type: type,
			id: id,
			body: body
		})
		.get('_id');
	},
	find_by_name: function(query, type) {
		return client.search({
			index: 'bookbrainz',
			type: type ? type : null,
			body: {
				query: {
					wildcard: {
						name: '*' + query + '*'
					}
				}
			}
		});
	}
};

module.exports = search;
