// server.js
// Copyright 2014 Patrick Meade.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//---------------------------------------------------------------------------

// load configuration
var config = require('./config');

// load and configure the ORM connection
var Sequelize = require('sequelize');
var sequelize = new Sequelize(
        config.db.dbname,
        config.db.username,
        config.db.password,
        config.db.options);

// load and configure the restmud application
var restmud = require('./lib/restmud');
var server = restmud.create();

// define ORM models for the application
var models = require('./lib/models/models');
models.define(sequelize, server);
sequelize.sync();

// begin listening for connections
server.listen(config.rest.port);

//---------------------------------------------------------------------------
// end of server.js
