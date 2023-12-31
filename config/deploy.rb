
# Change these
server '167.179.64.160', port: 22, roles: [:web, :app, :db], primary: true
set :repo_url,    'git@github.com:VuQuoc18/telegram-aution.git'  
set :application,   'telegram-aution'
set :user, 'root'
set :puma_threads,  [4, 16]  
set :puma_workers,  0  
# set :rvm_type, :system
# Don't change these unless you know what you're doing
set :pty,             true
set :use_sudo,        true
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/rails/"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :linked_dirs, fetch(:linked_dirs, []).push('public/system')
set :linked_files, %w(config/database.yml config/application.yml)
set :linked_dirs, %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads storage)
set :ssh_options, { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }

set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, false 

## Defaults:
set :scm,           :git
set :branch,        :master

namespace :puma do
    desc 'Create Directories for Puma Pids and Socket'
    task :make_dirs do
        on roles(:app) do
        execute "mkdir #{shared_path}/tmp/sockets -p"
        execute "mkdir #{shared_path}/tmp/pids -p"
        execute "mkdir #{release_path}/public/downloads -p"
        end
    end

    before :start, :make_dirs
    end

    namespace :deploy do
    desc "Make sure local git is in sync with remote."
    task :check_revision do
        on roles(:app) do
        unless `git rev-parse HEAD` == `git rev-parse origin/master`
            puts "WARNING: HEAD is not the same as origin/master"
            puts "Run `git push` to sync changes."
            exit
        end
        end
    end

    desc 'Initial Deploy'
    task :initial do
        on roles(:app) do
        before 'deploy:restart', 'puma:start'
        invoke 'deploy'
        end
    end

    desc 'Restart application'
    task :restart do
        on roles(:app), in: :sequence, wait: 5 do
        Rake::Task["puma:restart"].reenable
        invoke 'puma:restart'
        end
    end

    before :starting,     :check_revision
    # after  :finishing,    :compile_assets
    after  :finishing,    :cleanup
    # after  :finishing,    :restart
end

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma
