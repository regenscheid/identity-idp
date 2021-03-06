Identity-IdP (Upaya)
====================

[![Build Status](https://travis-ci.org/18F/identity-idp.svg?branch=master)](https://travis-ci.org/18F/identity-idp)
[![Code Climate](https://codeclimate.com/github/18F/identity-idp/badges/gpa.svg)](https://codeclimate.com/github/18F/identity-idp)
[![Test Coverage](https://codeclimate.com/github/18F/identity-idp/badges/coverage.svg)](https://codeclimate.com/github/18F/identity-idp/coverage)
[![security](https://hakiri.io/github/18F/identity-idp/master.svg)](https://hakiri.io/github/18F/identity-idp/master)
[![accessibility](https://continua11y.18f.gov/18F/identity-idp.svg?branch=master)](https://continua11y.18f.gov/18F/identity-idp)

A proof-of-concept Identity Management System.

**Notice:** This project is still in alpha.

### Local development

#### Dependencies

- Ruby 2.3.1
- [Postgresql](http://www.postgresql.org/download/)
- [Redis 2.8+](http://redis.io/)
- [Node.js v4.4.x](https://nodejs.org)

Testing dependencies:
- [PhantomJS](http://phantomjs.org)

#### Setting up and running the app

1. Make sure you have a working development environment with all the
  [dependencies](#dependencies) installed. On a Mac, the easiest way
  to set up a development environment is by running our [Laptop]
  script. The script will install all of this project's dependencies.

1. Make sure Postgres and Redis are running. For example, on OS X:

  ```
  $ brew services start redis postgres
  ```

1. Run the following command to set up the environment:

  ```
  $ make setup
  ```

  This command copies sample configuration files, installs required gems
  and sets up the database.

1. Run the app server with:

  ```
  $ make run
  ```

If you want to develop without and internet connection, you can set
`RAILS_OFFLINE=1` in your environment. This disables the `mx` record
check on email addresses.

If you want to measure the app's performance in development, set the
`rack_mini_profiler` option to `'on'` in `config/application.yml` and
restart the server. See the [rack_mini_profiler] gem for more details.

[Laptop]: https://github.com/18F/laptop
[rack_mini_profiler]: https://github.com/MiniProfiler/rack-mini-profiler

#### Using Docker

1. Download, install, and launch [Docker]

1. Set up the Docker image

  ```
  $ bin/setup --docker
  ```

[Docker]: https://docs.docker.com/engine/getstarted/step_one/#step-1-get-docker

More useful Docker commands:

* Start the container: `docker-compose up`
* Stop this running container: `docker-compose stop`
* Stop and delete the containers: `docker-compose down`
* Open a shell in the web container: `docker-compose run --rm web bash`

See the Docker Compose [docs](https://docs.docker.com/compose/install/) for
more information.

[Docker Compose]: (https://docs.docker.com/compose/install/)

### Viewing the app locally

Once it is up and running, the app will be accessible
at `http://localhost:3000/`. Email messages will be visible in MailCatcher
at `http://localhost:1080/`.

### Running Tests

Make sure you have [PhantomJS](http://phantomjs.org) installed prior to running
tests. On OS X, PhantomJS can be installed with Homebrew via: `brew install
phantomjs`. For other platforms, refer to the [PhantomJS download
page](http://phantomjs.org/download.html).

To run all the tests:

```
$ make test
```


See RSpec [docs](https://relishapp.com/rspec/rspec-core/docs/command-line) for
more information.

Run security scanner

```
$ make brakeman
```

### Deploying

We currently run a demo environment at https://idp.demo.login.gov.
Core developers can deploy to those hosts with [Capistrano](http://capistranorb.com)
using the following command:

```
$ cap <env/stage> deploy
```

You will need to provide a copy of your SSH public key and you may need to
provide your IP address if you are not in a GSA building or on the GSA VPN.
Post a message in the Slack channel if you need help.

Note: server secrets are currently manually configured. If you deploy to an
environment, make sure to update any required configuration in application.yml
and be sure any worker hosts are also updated. 

To restart the web server (on a web host, from /srv/idp/current)

```
$ touch tmp/restart.txt
```

To get status of the background workers (on a worker host):

```
$ sudo monit status
```

To restart the background workers:

```
$ sudo monit restart sidekiq_idp_production0
```

### Why 'Upaya'?

"skill in means" https://en.wikipedia.org/wiki/Upaya
