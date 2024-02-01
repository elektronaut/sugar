[![Build](https://github.com/elektronaut/sugar/workflows/Build/badge.svg)](https://github.com/elektronaut/sugar/actions)
[![Code Climate](https://codeclimate.com/github/elektronaut/sugar/badges/gpa.svg)](https://codeclimate.com/github/elektronaut/sugar)
[![Test Coverage](https://codeclimate.com/github/elektronaut/sugar/badges/coverage.svg)](https://codeclimate.com/github/elektronaut/sugar)

# Sugar

Sugar is a modern open-source forum optimized for performance and usability,
written in Ruby on Rails.

## Dependencies

* [Ruby 2.0+](https://www.ruby-lang.org/en/)
* [Bundler](http://bundler.io/)
* [Redis](http://redis.io/)
* [Java](http://www.java.com/en/download/index.jsp)
* libmagic
* [PostgreSQL](http://www.postgresql.org/)

## Installation

If you want to hack on Sugar, the easiest way to get up and running is using
Docker Compose:

    $ docker-compose run rails bin/setup
    $ docker-compose up

Sugar is now running on [localhost:3000](http://localhost:3000/).

You can run the tests and linters with:

    $ docker-compose run rails bin/rspec
    $ docker-compose run rails bin/rubocop


## Deploying Sugar

Sugar is deployed like a regular Rails app, see the
[official Rails site](http://rubyonrails.org/deploy). A sample Capistrano
recipe is provided `config/deploy.rb.dist`.

## <a id="configuration"></a> Configuring Sugar

Most of Sugar is configured with a web interface. However, a few details must
be sorted out before the app starts. The defaults should be fine for
development, but you need tweak these settings for production use with
environment variables.

Environment variable  | Required | Info
----------------------|----------|-----------------------------------------------------------------------
SUGAR_SECRET_KEY_BASE | Yes      | Set to a long, random string
SUGAR_SESSION_KEY     | -        | Default: `_sugar_session`
SUGAR_DB_DATABASE     | -        | Default: `sugar_<%= Rails.env %>`
SUGAR_DB_HOST         | -        | Default: `localhost`
SUGAR_DB_USERNAME     | -        | Default: `rails`
SUGAR_DB_PASSWORD     | -        | Default: ``
S3_BUCKET             | -        | Default: none, set if you want to use S3
S3_KEY_ID             | -        | Default: none, set if you want to use S3
S3_SECRET             | -        | Default: none, set if you want to use S3
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
