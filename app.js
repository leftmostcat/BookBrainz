/* vim: set ts=4 sw=4 : */

var express = require('express');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var session = require('express-session');
var bodyParser = require('body-parser');
var passport = require('passport');
var http = require('http');
var https = require('https');
var fs = require('fs');

var settings = require('./config/settings');

var MusicBrainzStrategy = require('./lib/passport-musicbrainz');
var knex = require('knex');

knex.knex = knex.initialize({
	client: 'pg',
	connection: {
		host: settings.database.host,
		user: settings.database.user,
		password: settings.database.password,
		database: settings.database.database
	}
});

var Editor = require('./data/editor');

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
				data = {
					name: profile.name,
					email: profile.email
				};

				return editor.insert(data)
					.then(function(result) {
						return editor.get_by_id(result[0]);
					})
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

var routes = require('./routes/index');
var book = require('./routes/book');
var creator = require('./routes/creator');

var app = express();

app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

app.use(favicon(path.join(__dirname, 'public/favicon.ico')));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded());
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use(session({
	name: 'sid',
	secret: settings.session.secret
}));

app.use(passport.initialize());
app.use(passport.session());

app.use('/', routes);
app.use('/book', book);
app.use('/creator', creator);

app.get('/login', passport.authenticate('musicbrainz', { scope: 'profile email' }));
app.get('/login/callback', passport.authenticate('musicbrainz'), function(req, res) {
	res.redirect('/');
});

app.use(function(req, res, next) {
		var err = new Error('Not Found');
		err.status = 404;
		next(err);
});

if (app.get('env') === 'development') {
		app.use(function(err, req, res) {
				res.status(err.status || 500);
				res.render('error', {
						message: err.message,
						error: err
				});
		});

		app.locals.pretty = true;
}

app.use(function(err, req, res) {
		res.status(err.status || 500);
		res.render('error', {
				message: err.message,
				error: {}
		});
});

var httpsOptions = {
	key: fs.readFileSync('config/bookbrainz.key'),
	cert: fs.readFileSync('config/bookbrainz.crt')
};

http.createServer(app).listen(settings.server.portHTTP);
https.createServer(httpsOptions, app).listen(settings.server.portHTTPS);

module.exports = app;
