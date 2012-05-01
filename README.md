Heroku Ruby Client
==================

The Heroku Ruby Client is used to interact with the Heroku API from Ruby.

For more about the Heroku API see <http://api-docs.heroku.com>.

[![Build Status](https://secure.travis-ci.org/heroku/heroku.rb.png)](https://secure.travis-ci.org/heroku/heroku.rb)

Usage
-----

Start by creating a connection to Heroku with your credentials:

    require 'heroku-api'

    heroku = Heroku::API.new(:api_key => API_KEY)

NOTE: You can leave out the `:api_key` if `ENV['HEROKU_API_KEY']` is set instead.

Now you can make requests to the api.

Requests
--------

What follows is an overview of commands you can run for the client.

For additional details about any of the commands, see the [API docs](http://api-docs.heroku.com).

### Add-ons

    heroku.delete('app', 'addon')     # remove 'addon' add-on from an 'app' app
    heroku.get_addons                 # see a listing of all available add-ons
    heroku.get_addons('app')          # see listing of installed add-ons for 'app' app
    heroku.post_addon('app', 'addon') # add 'addon' add-on to 'app' app
    heroku.put_addon('app', 'addon')  # update 'addon' add-on on 'app' app

### Apps

    heroku.delete_app('app')                # delete an app named 'app'
    heroku.get_apps                         # get a list of your apps
    heroku.get_app('app')                   # get info about an app named 'app'
    heroku.post_app                         # create an app with a generated name and the default stack
    heroku.post_app('name' => 'app')        # create an app with a specified name
    heroku.post_app_maintenance('app', '1') # toggle maintenance mode
    heroku.put_app('name' => 'myapp')       # update an app to have a different name

### Collaborators

    delete_collaborator('app', 'email@example.com') # remove 'email@example.com' collaborator from 'app' app
    get_collaborators('app')                        # list collaborators for 'app' app
    post_collaborator('app', 'email@example.com')   # add 'email@example.com' collaborator to 'app' app

### Config Variables

    delete_config_var('app', 'KEY')           # remove 'KEY' key from 'app' app
    get_config_vars('app')                    # get list of config vars for 'app' app
    put_config_vars('app', 'KEY' => 'value')  # set 'KEY' key to 'value' for 'app' app

### Domains

    delete_domain('app', 'example.com') # remove the 'example.com' domain from the 'app' app
    get_domains('app')                  # list configured domains for the 'app' app
    post_domains('app', 'example.com')  # add 'example.com' domain to the 'app' app

### Keys

    delete_key('user@hostname.local') # remove the 'user@hostname.local' key
    delete_keys                       # remove all keys
    get_keys                          # list configured keys
    post_key('key data')              # add key defined by 'key data'

### Logs

    get_logs('app') # return logs information for 'app' app

### Processes

    get_ps('app')                             # list current processes for 'app' app
    post_ps('app', 'command')                 # run 'command' command in context of 'app' app
    post_ps_restart('app')                    # restart all processes for 'app' app
    post_ps_scale('app', 'type', 'quantity')  # scale 'type' type processes to 'quantity' for 'app' app
    post_ps_stop('app', 'ps' => 'web.1')      # stop 'web.1' process for 'app' app
    post_ps_stop('app', 'type' => 'web')      # stop all 'web' processes for 'app' app
    put_dynos('app', 'dynos')                 # set number of dynos for bamboo app 'app' to 'dynos'
    put_workers('app', 'workers')             # set number of workers for bamboo app 'app' to 'workers'

    post_ps_restart('app', 'ps' => 'web.1')   # restart 'web.1' process for 'app' app

### Releases

    get_releases('app')       # list of releases for 'app' app
    get_release('app', 'v#')  # get details of 'v#' release for 'app' app
    post_release('app', 'v#') # rollback 'app' app to 'v#' release

### Stacks

    get_stack('app')          # list available stacks
    put_stack('app', 'stack') # migrate 'app' app to 'stack' stack

### User

    get_user                  # list user info

Mock
----

For practice or testing you can also use a simulated Heroku:

    require 'heroku-api'

    heroku = Heroku::API.new(:api_key => API_KEY, :mock => true)

After that commands should still behave the same, but they will only modify some local data instead of updating the state of things on Heroku.

Tests
-----

To run tests, first set `ENV['HEROKU_API_KEY']` to your api key.  Then use `bundle exec rake` to run mock tests or `MOCK=false bundle exec rake` to run integration tests.

Meta
----

Released under the [MIT license](http://www.opensource.org/licenses/mit-license.php).
