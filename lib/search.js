/* vim: set ts=4 sw=4 : */

var elasticsearch = require('elasticsearch');

var search = {};

var client;

search.init = function() {
	client = new elasticsearch.Client({
		host: 'localhost:9200'
	});
};

search.index = function(type, id, body) {
	return client.index({
		index: 'bookbrainz',
		type: type,
		id: id,
		body: body
	})
	.get('_id');
};

search.find_by_name = function(query, type) {
	return client.search({
		index: 'bookbrainz',
		type: type ? type : null,
		body: {
			query: {
				match: {
					'name.search': {
						query: query,
						minimum_should_match: '80%'
					}
				}
			}
		}
	});
};

search.autocomplete = function(query, type) {
	return client.search({
		index: 'bookbrainz',
		type: type,
		body: {
			query: {
				match: {
					'name.autocomplete': {
						query: query,
						slop: 10
					}
				}
			}
		}
	});
};

module.exports = search;
