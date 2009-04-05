#require 'mongrel_cluster/recipes'

set :application, "b3s"
set :repository,  "http://svn.elektronaut.no/svn/b3s/trunk"
set :runner,      "app"
set :user,        "app"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "b3s.elektronaut.no"
role :web, "b3s.elektronaut.no"
role :db,  "b3s.elektronaut.no", :primary => true

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

#set :mongrel_conf, "#{deploy_to}/#{current_dir}/config/mongrel_cluster.yml"
#set :flush_cache, true

desc "Create shared directories"
task :create_shared_dirs, :roles => [:web,:app] do
	run "mkdir #{deploy_to}/#{shared_dir}/cache"
	run "mkdir #{deploy_to}/#{shared_dir}/public_cache"
	run "mkdir #{deploy_to}/#{shared_dir}/sockets"
	run "mkdir #{deploy_to}/#{shared_dir}/sessions"
	run "mkdir #{deploy_to}/#{shared_dir}/index"
	run "mkdir #{deploy_to}/#{shared_dir}/sphinx"
	run "touch #{deploy_to}/#{shared_dir}/database.yml"
end

desc "Fix permissions"
task :fix_permissions, :roles => [:web, :app] do
	run "chmod -R u+x #{deploy_to}/#{current_dir}/script/*"
	run "chmod u+x    #{deploy_to}/#{current_dir}/public/dispatch.*"
	run "chmod u+rwx  #{deploy_to}/#{current_dir}/public"
end

desc "Create symlinks"
task :create_symlinks, :roles => [:web,:app] do
	#run "ln -s #{deploy_to}/#{shared_dir}/system #{deploy_to}/#{current_dir}/public/system"
	run "ln -s #{deploy_to}/#{shared_dir}/cache #{deploy_to}/#{current_dir}/tmp/cache"
	run "ln -s #{deploy_to}/#{shared_dir}/sockets #{deploy_to}/#{current_dir}/tmp/sockets"
	run "ln -s #{deploy_to}/#{shared_dir}/sessions #{deploy_to}/#{current_dir}/tmp/sessions"
	run "ln -s #{deploy_to}/#{shared_dir}/index #{deploy_to}/#{current_dir}/index"
	run "ln -s #{deploy_to}/#{shared_dir}/public_cache #{deploy_to}/#{current_dir}/public/cache"
	run "ln -s #{deploy_to}/#{shared_dir}/database.yml #{deploy_to}/#{current_dir}/config/database.yml"
	run "ln -s #{deploy_to}/#{shared_dir}/session_key #{deploy_to}/#{current_dir}/config/session_key"
	run "ln -s #{deploy_to}/#{shared_dir}/doodles #{deploy_to}/#{current_dir}/public/doodles"
	run "ln -s #{deploy_to}/#{shared_dir}/sphinx #{deploy_to}/#{current_dir}/db/sphinx"
end

namespace :deploy do
    namespace :web do

        desc "Present a maintenance page to visitors. Message is customizable with the REASON enviroment variable."
        task :disable, :roles => [:web, :app] do
            if reason = ENV['REASON']
                run("cd #{deploy_to}/current; /usr/bin/rake b3s:disable_web REASON=\"#{reason}\"")
            else
                run("cd #{deploy_to}/current; /usr/bin/rake b3s:disable_web")
            end
        end
        
        desc "Makes the application web-accessible again."
        task :enable, :roles => [:web, :app] do
            run("cd #{deploy_to}/current; /usr/bin/rake b3s:enable_web")
        end

    end

	desc "Restart Application"
	task :restart, :roles => :app do
		run "touch #{current_path}/tmp/restart.txt"
	end
end

after "deploy:setup", :create_shared_dirs
after "deploy:symlink", :fix_permissions
after "deploy:symlink", :create_symlinks


