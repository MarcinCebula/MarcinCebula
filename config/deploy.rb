require "bundler/capistrano"

set :default_environment, {
  'RAILS_ENV' =>  'production',
  'PATH'      =>  '/home/ubuntu/.rvm/gems/ruby-1.9.3-p0@MarcinCebula/bin:/home/ubuntu/.rvm/gems/ruby-1.9.3-p0@global/bin:/home/ubuntu/.rvm/rubies/ruby-1.9.3-p0/bin:/home/ubuntu/.rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games',
  'GEM_PATH'  =>  '/home/ubuntu/.rvm/gems/ruby-1.9.3-p0@MarcinCebula:/home/ubuntu/.rvm/gems/ruby-1.9.3-p0@global',
  'GEM_HOME'  =>  '/home/ubuntu/.rvm/gems/ruby-1.9.3-p0@MarcinCebula',
  'rvm_path'  =>  '/home/ubuntu/.rvm',
  'NGINX_HOME'=>  '/opt/nginx'
}

set :normalize_asset_timestamps, false
set :ssh_options, {:forward_agent => true}
set :use_sudo, false
ssh_options[:keys] = File.join(ENV["HOME"], ".ssh", "id_rsa")


server_ip = "50.17.232.142"
set :user, "ubuntu"

set :application, "MarcinCebula"
set :repository,  "git@github.com:MarcinRKL/MarcinKCebula.git"
# set :branch, "staging"
set :deploy_to, "/opt/apps/#{application}"
set :scm, "git"

role :web, server_ip                          # Your HTTP server, Apache/etc
role :app, server_ip                          # This may be the same as your `Web` server
role :db,  server_ip, :primary => true        # This is where Rails migrations will run
#role :db,  "your slave db-server here"


namespace :deploy do
  
  LocalSharePath = File.join(`echo $SNOZZBERRYLABS`.strip, 'SHARED', 'MarcinCebula').to_s

  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
    # run "cd #{release_path} && rvmsudo rake workers:kilall"
  end
  desc "Sync and symlink shared files"
  task :sync_and_symlink_shared do
    [:sync_share, :symlink_shared].each { |t| build t }
  end
  
  desc "Sync the public/assets directory."
  task :sync do
    desc "update config folder"
      `rsync -Paz --rsh "ssh -i #{ssh_options[:keys]}" --rsync-path "rsync" "#{LocalSharePath}/config" "#{user}@#{server_ip}":"#{shared_path}/"`		    
      # `rsync -Paz --rsh "ssh -i #{ssh_options[:keys]}" --rsync-path "sudo rsync" "#{LocalSharePath}/config" "#{user}@#{roles[:web].servers}":"#{shared_path}/"`     
      # `rsync -Paz --rsh "ssh -i #{ssh_options[:keys]}" --rsync-path "sudo rsync" "#{LocalSharePath}/log" "#{user}@#{roles[:web].servers}":"#{shared_path}/"`
  end
  desc "Symlink shared configs and folders on each release."
  task :symlink do
    run "ln -nfs #{shared_path}/config/mongoid.yml #{release_path}/config/mongoid.yml"
    run "ln -nfs #{shared_path}/config/initializers/secret_token.rb #{release_path}/config/initializers/secret_token.rb"
    run "ln -nfs #{shared_path}/config/initializers/session_store.rb #{release_path}/config/initializers/session_store.rb"
    
    # run "ln -nfs #{shared_path}/config/initializers/devise.rb #{release_path}/config/initializers/devise.rb"
    run "cd #{shared_path} && [ -d pids ] || mkdir pids"
    run "cd #{shared_path} && [ -d log ] || mkdir log"
  end
  desc "Bundle and Migrate Project"
  task :bundle do 
    run "cd #{release_path} && bundle install"
    run "cd #{release_path} && rake db:create"
    run "cd #{release_path} && rake db:migrate"
    run "cd #{release_path} && rake db:seed"
  end
  desc "run rake tasts. Create folders"
  task :setup do 
    run "cd #{release_path} && rake setup:all"
  end
  
end

namespace :rvm do
  desc 'Trust rvmrc file'
  task :trust_rvmrc do
    run "rvm rvmrc trust #{current_release}"
  end
end

namespace :info do 
  desc "print deploy variables"
  task :var_log do 
    puts "ssh_options[:keys] : #{ssh_options[:keys]}"
    puts "local_share_path : #{LocalSharePath}"
    puts "user : #{user}"
    puts "application : #{roles[:web].servers}"
    puts "shared_path : #{shared_path}"
    puts "server_ip : #{server_ip}"
    puts "user : #{user}"
  end
end

namespace :cron do
  desc "Update the crontab file"
  task :update_crontab do
    run "cd #{release_path} && whenever --set environment=production --update-crontab wrynku"
  end
end

after 'deploy:update_code', 'rvm:trust_rvmrc', 'deploy:sync','deploy:symlink', 'deploy:bundle'

## Just precompile before push
#deploy:assets:precompile'

# require './config/boot'
# require 'airbrake/capistrano'
