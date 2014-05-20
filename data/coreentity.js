/* vim: ts=4:sw=4 */

var super_ = require('./entity');
var util = require('util');

function CoreEntity() {
	CoreEntity.super_.call(this);
}

util.inherits(CoreEntity, super_);

module.exports = CoreEntity;
