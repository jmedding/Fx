set :user, 'jon'
set :application, "fx"
set :repository,  "git@github.com:jmedding/Fx.git"

set :domain, "pragmaticriskmanagement.com"

set :deploy_to, "/var/www/#{application}"

#default_run_options[:pty] = true

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :deploy_via, :remote_cache
#set :deploy_via, :copy
ssh_options[:forward_agent] = true

set :scm, 'git'
set :branch, 'master'
set :scm_verbose, true
set :use_sudo, false


namespace :deploy do
    desc "Restart Application"
    task :restart, :roles => :app do
      run "touch #{current_path}/tmp/restart.txt"
    end

    desc "Make symlink for database.yml" 
    task :symlink_dbyaml do
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
    end

    desc "Create empty database.yml in shared path" 
    task :create_dbyaml do
      run "mkdir -p #{shared_path}/config" 
      put '', "#{shared_path}/config/database.yml" 
	end
	
end

after 'deploy:setup', 'deploy:create_dbyaml'
after 'deploy:update_code', 'deploy:symlink_dbyaml'

after "deploy", "deploy:cleanup"
