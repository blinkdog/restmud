# config.md
Documentation for the parameters found in `/config.json`

## baseUri
The URI that serves as the HATEOAS entry-point for the application.
The trailing slash should be excluded.

## db
Configuration for the database used by restmud

### dbname
The name of the database

### options
An object with options

#### dialect
The dialect you of the database you are connecting to. One of:
`mysql`, `postgres`, `sqlite` and `mariadb`

#### host
The host of the relational database.

#### port
The port of the relational database.

### password
The password which is used to authenticate against the database.

### username
The username which is used to authenticate against the database.

## rest
Configuration for the REST(HTTP) protocol services provided by the server.

### port
The port on which the server will listen for RESTful requests.

## sourceUri
The URI used to provide the Corresponding Source as required by Section 13
of the GNU Affero General Public License. This URI may provide the
Corresponding Source itself, or it may point to a repository (i.e.: a
GitHub URI) where the Corresponding Source can be obtained at no charge.
