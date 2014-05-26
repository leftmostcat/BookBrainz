/* vim: set ts=4 sw=4 : */

var passport = require('passport');

var MusicBrainzStrategy = require('./passport-musicbrainz');
var settings = require('../config/settings');
var Editor = require('../data/editor');

var auth = {
	init: function(app) {
		passport.use(new MusicBrainzStrategy({
			clientID: settings.oauth2.clientID,
			clientSecret: settings.oauth2.clientSecret,
			callbackURL: settings.oauth2.callbackURL
		}, function(accessToken, refreshToken, profile, done) {
			var editor = new Editor();

			editor.get_by_name(profile.name)
				.then(function(result) {
					if (result.length) {
						return result;
					}
					else {
						var data = {
							name: profile.name,
							email: profile.email
						};

						return editor.insert(data)
							.then(function(result) {
								return editor.get_by_id(result[0]);
							});
					}
				})
				.catch(function(err) {
					done(err);
				})
				.done(function(result) {
					done(null, result[0]);
				});
		}));

		passport.serializeUser(function(user, done) {
			done(null, user);
		});

		passport.deserializeUser(function(user, done) {
			done(null, user);
		});

		app.use(passport.initialize());
		app.use(passport.session());

		app.get('/login', passport.authenticate('musicbrainz', { scope: 'profile email' }));
		app.get('/login/callback', passport.authenticate('musicbrainz'), function(req, res) {
			var redirect = req.session.redirect_to ? req.session.redirect_to : '/';

			res.redirect(redirect);
		});
	},
	isAuthenticated: function(req, res, next) {
		if (req.isAuthenticated())
			return next();

		req.session.redirect_to = req.originalUrl;
		res.redirect('/login');
	}
};

module.exports = auth;
