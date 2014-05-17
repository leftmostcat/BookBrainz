var super_ = require('./entity');
var util = require('util');

function CoreEntity(app) {
	CoreEntity.super_.call(this, app);
}

util.inherits(CoreEntity, super_);

CoreEntity.prototype.get_by_uuid = function(uuid, callback) {
	// XXX: Verify that the UUID passed in is, in fact, a UUID

	this.get_by_id(uuid, callback);
};

module.exports = CoreEntity;
