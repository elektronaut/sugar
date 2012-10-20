# Sugar [![Build Status](https://travis-ci.org/elektronaut/sugar.png)](https://travis-ci.org/elektronaut/sugar)

Sugar is a free, open-source forum optimized for performance and usability, written in Ruby on Rails.


## Features

Sugar aims for simplicity, and is first and foremost built for performance, especially with a high volume of posts. There's a few interesting bullet points, though:

* Publically browseable, signup required or invite-only
* Realtime discussions (via AJAX)
* iPhone version
* OpenID support
* Unread posts tracking
* Following and favoriting discussions
* Mouse drawing using Napkin
* Google Reader/GMail style keyboard navigation
* Syntax highlighting of code
* Google Maps support
* Loads data from Twitter, Flickr, Last.fm
* Custom stylesheets

Things you *WON'T* find in Sugar:

* Threaded discussions
* User groups and access control lists
* Emoticons and signatures


## Requirements, and how to install them

Sugar is built on Ruby on Rails 3.2, requires Ruby 1.9 and supports MySQL, Postgres and SQLite.

You'll need to have Redis installed. Sugar connects to localhost by default, which should be fine in most cases.

Install Bundler (if you haven't) and use it to install the rest of the required gems:

```
gem install bundler
bundle install
```

## Installation

Copy the sample configuration files, then edit them.

```
cp config/database.yml.dist config/database.yml
cp config/initializers/sugar.rb.dist config/initializers/sugar.rb
```

Next, create and migrate the database:

```
bundle exec rake db:create
bundle exec rake db:migrate
```

You're now ready to start the development server:

```
bundle exec rails server
```


## Credits

Although it's written from scratch, the look and feel of Sugar was inspired by Vanilla, an open-source forum by Lussumo. Thanks to the members of the B3S community for feedback, ideas and encouragement, names far too many to be mentioned. Napkin was written by Branden Hall of [Automata Studios](http://automatastudios.com/).

The name? It's what Butterscotch is made of, and it's totally sweet.


## License

Copyright (c) 2008 Inge Jørgensen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
