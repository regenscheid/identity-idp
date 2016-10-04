#################
# GLOBAL CONFIG
#################
set :application, 'idp'
set :assets_roles, [:web, :worker]
# set branch based on env var or ask with the default set to the current local branch
set :branch, ENV['branch'] || ENV['BRANCH'] || ask(:branch, `git branch`.match(/\* (\S+)\s/m)[1])
set :bundle_without, 'deploy development doc test'
set :deploy_to, '/srv/idp'
set :deploy_via, :remote_cache
set :keep_releases, 5
set :linked_files, %w(certs/saml.crt
                      config/application.yml
                      config/database.yml
                      config/newrelic.yml
                      keys/saml.key.enc)
set :linked_dirs, %w(bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system)
set :passenger_roles, [:app, :web]
set :passenger_restart_wait, 5
set :passenger_restart_runner, :sequence
set :rails_env, :production
set :repo_url, 'https://github.com/18F/identity-idp.git'
set :sidekiq_options, ''
set :sidekiq_queue, [:analytics, :mailers, :sms, :voice]
set :sidekiq_monit_use_sudo, true
set :sidekiq_user, 'ubuntu'
set :ssh_options, forward_agent: false, user: 'ubuntu'
set :whenever_roles, [:app]

#########
# TASKS
#########
namespace :deploy do
  desc 'Install npm packages required for asset compilation with browserify'
  task :browserify do
    on roles(:app, :web), in: :sequence do
      within release_path do
        execute :npm, 'install'
      end
    end
  end

  before 'assets:precompile', :browserify
end
