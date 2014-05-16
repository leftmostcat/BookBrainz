var express = require('express');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');

var routes = require('./routes/index');
var book = require('./routes/book');

var app = express();

var pgsql = require('./lib/pgsql');

app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

app.use(favicon(path.join(__dirname, 'public/favicon.ico')));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded());
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', routes);
app.use('/book', book);

app.use(function(req, res, next) {
		var err = new Error('Not Found');
		err.status = 404;
		next(err);
});

if (app.get('env') === 'development') {
		app.use(function(err, req, res, next) {
				res.status(err.status || 500);
				res.render('error', {
						message: err.message,
						error: err
				});
		});

		app.locals.pretty = true;
}

app.use(function(err, req, res, next) {
		res.status(err.status || 500);
		res.render('error', {
				message: err.message,
				error: {}
		});
});

app.set('db', new pgsql());

module.exports = app;
