
set :application, 'kalading_backend'
set :repo_url, 'git@bitbucket.org:nanamiwang/kalading.git'
set :deploy_user, 'deployer'
set :scm, :git

# rbenv
set :rbenv_type, :user
set :rbenv_ruby, '2.1.5'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

set :keep_releases, 5

# puma
set :puma_config_file, "config/puma.rb"
set :puma_role, :app

# files we want symlinking to specific entries in shared
set :linked_files, %w{config/database.yml config/mongoid.yml}

# dirs we want symlinking to shared
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public }

namespace :deploy do
  after :finishing, 'deploy:cleanup'
end
