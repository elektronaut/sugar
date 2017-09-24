[![Build Status](https://travis-ci.org/elektronaut/sugar.svg?branch=master)](https://travis-ci.org/elektronaut/sugar)
[![Code Climate](https://codeclimate.com/github/elektronaut/sugar/badges/gpa.svg)](https://codeclimate.com/github/elektronaut/sugar)
[![Test Coverage](https://codeclimate.com/github/elektronaut/sugar/badges/coverage.svg)](https://codeclimate.com/github/elektronaut/sugar)
[![Dependency Status](https://gemnasium.com/elektronaut/sugar.svg)](https://gemnasium.com/elektronaut/sugar)
[![Security](https://hakiri.io/github/elektronaut/sugar/master.svg)](https://hakiri.io/github/elektronaut/sugar/master)

# Sugar

Sugar is a modern open-source forum optimized for performance and usability,
written in Ruby on Rails.

## Dependencies

* [Ruby 2.0+](https://www.ruby-lang.org/en/)
* [Bundler](http://bundler.io/)
* [Redis](http://redis.io/)
* [Java](http://www.java.com/en/download/index.jsp)
* libmagic

SQLite is supported, but you probably want
[PostgreSQL](http://www.postgresql.org/) or [MySQL](http://www.mysql.com/) for
production use.

## Installation

If you want to hack on Sugar, the easiest way to get up and running is with
[sugar-dev-box](https://github.com/elektronaut/sugar-dev-box). It provides a
virtual development environment, and only requires VirtualBox and Vagrant.

Otherwise:

    $ git clone https://github.com/elektronaut/sugar.git
    $ cd sugar
    $ bundle
    $ bin/rake db:create
    $ bin/rake db:migrate

This assumes you have MySQL running on localhost, with a user named `rails`
with no password. See [Configuring Sugar](#configuration) if your setup
differs.

Now you can start Solr and the development server:

    $ bin/sunspot-solr start
    $ bin/rails server

Sugar is now running on [localhost:3000](http://localhost:3000/).

## Deploying Sugar

Sugar is deployed like a regular Rails app, see the
[official Rails site](http://rubyonrails.org/deploy). A sample Capistrano
recipe is provided `config/deploy.rb.dist`.

For production use, you'll want a full grown Solr setup. See the
[Sunspot documentation](https://github.com/sunspot/sunspot) for guides on how
to get up and running.

[Heroku](https://www.heroku.com/) is currently not supported.

## <a id="configuration"></a> Configuring Sugar

Most of Sugar is configured with a web interface. However, a few details must
be sorted out before the app starts. The defaults should be fine for
development, but you need tweak these settings for production use with
environment variables.

Environment variable  | Required | Info
----------------------|----------|-----------------------------------------------------------------------
SUGAR_SECRET_KEY_BASE | Yes      | Set to a long, random string
SUGAR_SECRET_TOKEN    | -        | Use if you are upgrading from Rails 3
SUGAR_SESSION_KEY     | -        | Default: `_sugar_session`
SUGAR_DB              | -        | Database backend. Default: `mysql`, also valid: `postgresql`, `sqlite`
SUGAR_DB_DATABASE     | -        | Default: `sugar_<%= Rails.env %>`
SUGAR_DB_HOST         | -        | Default: `localhost`
SUGAR_DB_USERNAME     | -        | Default: `rails`
SUGAR_DB_PASSWORD     | -        | Default: `rails` for PostgreSQL, blank for MySQL
SENTRY_DSN            | -        | Default: none, set if you want to use Sentry

## Credits

Thanks to the members of the B3S community for feedback, ideas and
encouragement, names far too many to be mentioned. Napkin was written by
Branden Hall of [Automata Studios](http://automatastudios.com/).

## License

Copyright (c) 2008 Inge Jørgensen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
