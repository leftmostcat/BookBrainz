/* vim: ts=4:sw=4 */

var super_ = require('./entity');
var util = require('util');

function CoreEntity() {
	CoreEntity.super_.call(this);
}

util.inherits(CoreEntity, super_);

CoreEntity.prototype.get_by_uuid = function(uuid, callback) {
	// XXX: Verify that the UUID passed in is, in fact, a UUID

	this.get_by_id(uuid, callback);
};

module.exports = CoreEntity;
