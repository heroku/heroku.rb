Heroku Ruby Client
==================

The Heroku Ruby Client is used to interact with the Heroku API from Ruby.

For more about the Heroku API see <http://api-docs.heroku.com>.

[![Build Status](https://secure.travis-ci.org/heroku/heroku.rb.png)](https://secure.travis-ci.org/heroku/heroku.rb)

Usage
-----

Start by creating a connection to Heroku with your credentials:

    heroku = Heroku::Connection.new(:api_key => API_KEY)

NOTE: You can leave out the `:api_key` if `ENV['HEROKU_API_KEY']` is set instead.

Now you can make requests to the api.

Apps
----

The apps commands allow you to interact with your apps on heroku.

    # BASIC
    heroku.get_apps           # get a list of your apps
    heroku.post_apps          # create an app with generated name and default stack
    heroku.get_app('app')     # get info about an app named app
    heroku.delete_app('app')  # delete an app named app

    # ADVANCED
    heroku.post_apps('name' => 'app') # create an app with a specified name

Mock
----

For practice or testing you can also use a simulated Heroku:

    heroku = Heroku::Connection.new(:api_key => API_KEY, :mock => true)

After that commands should still behave the same, but they will only modify some local data instead of updating the state of things on Heroku.

Meta
----

Released under the [MIT license](http://www.opensource.org/licenses/mit-license.php).
