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

var settings = require('./config/settings');
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

var auth = require('./lib/auth');

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

auth.init(app);

app.use('/', routes);
app.use('/book', book);
app.use('/creator', creator);

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

http.createServer(app).listen(settings.server.port);

module.exports = app;
