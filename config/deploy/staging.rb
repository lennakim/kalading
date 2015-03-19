# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

role :app, %w{deployer@121.42.155.108}
role :web, %w{deployer@121.42.155.108}
role :db,  %w{deployer@121.42.155.108}

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

server '121.42.155.108', user: 'deployer', roles: %w{web app db}

set :ssh_options, {
  forward_agent: true,
  password: 'kalading'
}

set :stage, :staging
set :branch, 'master'
set :deploy_to, "/home/#{fetch(:deploy_user)}/backend"
set :rails_env, :staging
# set :puma_bind, "unix:///tmp/kalading-backend.sock"

set :enable_ssl, false

after 'deploy:publishing', 'puma:restart'
