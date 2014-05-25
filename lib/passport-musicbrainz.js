/* vim: set ts=4 sw=4 : */

var util = require('util');
var OAuth2Strategy = require('passport-oauth2');

function Strategy(options, verify) {
	options = options || {};
	options.authorizationURL = 'https://musicbrainz.org/oauth2/authorize';
	options.tokenURL = 'https://musicbrainz.org/oauth2/token';
	options.state = true;

	OAuth2Strategy.call(this, options, verify);
	this.name = 'musicbrainz';
}

util.inherits(Strategy, OAuth2Strategy);

Strategy.prototype.userProfile = function(accessToken, done) {
	this._oauth2.get('https://musicbrainz.org/oauth2/userinfo', accessToken, function(err, body, res) {
		if (err)
			return done(err);

		try {
			var json = JSON.parse(body);

			var profile = {
				name: json.sub,
				email: json.email,
				emailVerified: json.email_verified,
				website: json.website,
				gender: json.gender,
				profileURL: json.profile,
				timezone: json.zoneinfo
			};

			done(null, profile);
		} catch(e) {
			done(e);
		}
	});
};

module.exports = Strategy;
