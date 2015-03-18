#!/usr/bin/env puma

environment "production"
basedir = "/home/deployer/backend/kalading"

bind  "unix:///tmp/kalading-backend.sock"
pidfile  "/home/deployer/backend/shared/pids/kalading-backend-puma.pid"
state_path "/home/deployer/backend/shared/pids/kalading-backend-puma.state"

workers 2
threads 2, 4
daemonize true

preload_app!
activate_control_app