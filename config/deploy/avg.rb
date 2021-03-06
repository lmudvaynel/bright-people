namespace :deploy do
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end
end

desc "tail production log files"
task :tail_logs, :roles => :app do
  log_file = case ENV['log']
             when 'd' then 'delayed_job.log'
             else "#{rails_env}.log"
             end

  run "tail -f #{File.join(shared_path, 'log', log_file)}" do |channel, stream, data|
    puts  # for an extra line break before the host name
    puts "#{channel[:host]}: #{data}"
    break if stream == :err
  end
end

namespace :rails do
  desc "Open the rails console on one of the remote servers"
  task :console, :roles => :app do
    hostname = find_servers_for_task(current_task).first
    exec "ssh -l #{user} #{hostname} -t 'export LC_ALL=ru_RU.utf8 && \
                                         cd #{latest_release} && \
                                         source #{rvm_bin_path}/rvm && \
                                         source .rvmrc && \
                                         RAILS_ENV=#{rails_env} bundle exec rails c'"
  end
end

namespace :rake_exec do
  desc "Run a rake task on a remote server."
  # run like: cap staging rake:invoke task=a_certain_task
  task :invoke do
    run("cd #{latest_release}; RAILS_ENV=#{rails_env} rake #{ENV['task']}")
  end
end

namespace :delayed_job do
  desc "Restart the delayed_job process"
  task :restart, :roles => :app do
    run "cd #{latest_release}; RAILS_ENV=#{rails_env} script/delayed_job -n #{delayed_workers || 1} restart"
  end

  task :stop, :roles => :app do
    run "cd #{latest_release}; RAILS_ENV=#{rails_env} script/delayed_job stop"
  end
end

namespace :shared do
  task :symlinks, :roles => :app do
    run "ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
    run "ln -nfs #{shared_path}/config/sphinx.yml #{latest_release}/config/sphinx.yml"
  end

  task :disallow_robots, :roles => :app do
    run "ln -nfs #{shared_path}/config/robots.txt #{latest_release}/public/robots.txt"
  end
end

namespace :load_staging do
  task :db, :roles => :app do
    unless ENV['NOT_DUMP_DB']
      cache_dump = ENV['CACHE_DUMP'] ? true : false
      run "cd #{latest_release}; RAILS_ENV=#{rails_env} CACHE_DUMP=#{cache_dump} bundle exec rake staging:load_db"
    end
  end

  task :images, :roles => :app do
    reload_images = ENV['RELOAD_IMAGES'] ? true : false
    run "cd #{latest_release}; RAILS_ENV=#{rails_env} RELOAD_IMAGES=#{reload_images} bundle exec rake staging:load_images"
  end

  task :gallery_photo_new, :roles => :app do
    run "cd #{latest_release}; RAILS_ENV=staging bundle exec rails runner 'GalleryPhoto.destroy_all'"
    run "cd #{latest_release}; RAILS_ENV=staging bundle exec rake 'db:load_file[db/sample/festival_categories.yml]'"
    run "cd #{latest_release}; RAILS_ENV=staging PHOTOS_COUNT=600 bundle exec rails runner 'load Rails.root.join(\"db/sample/gallery_photos.rb\")'"
  end
end

require 'capistrano-unicorn'

namespace :unicorn do
  desc 'Reload unicorn'
  task :reload, :roles => :app, :except => {:no_release => true} do
    config_path = "#{current_path}/config/unicorn/#{rails_env}_#{stage}.rb"
    if remote_file_exists?(unicorn_pid)
      logger.important("Stopping...", "Unicorn")
      run "kill -s USR2 `cat #{unicorn_pid}`"
    else
      logger.important("No PIDs found. Starting Unicorn server...", "Unicorn")
      if remote_file_exists?(config_path)
        run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec unicorn -c #{config_path} -E #{rails_env} -D"
      else
        logger.important("Config file for \"#{unicorn_env}\" environment was not found at \"#{config_path}\"", "Unicorn")
      end
    end
  end

  desc 'Hard way to restart unicron'
  task :hard_reload, :roles => :app, :except => {:no_release => true} do
    config_path = "#{current_path}/config/unicorn/#{rails_env}.rb"
    if remote_file_exists?(unicorn_pid)
      logger.important("Stopping...", "Unicorn")
      run "kill -TERM `cat #{unicorn_pid}` || echo lol"
      run "rm #{unicorn_pid} || echo lol"
      run "rm /var/www/bright-people/current/tmp/unicorn.sock || echo lol"
      # Sometimes we need to wait
      sleep 5
      run "cd #{current_path} && RAILS_ENV=#{app_env} bundle exec unicorn -c #{config_path} -E #{rails_env} -D"
    else
      logger.important("No PIDs found. Starting Unicorn server...", "Unicorn")
      if remote_file_exists?(config_path)
        run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec unicorn -c #{config_path} -E #{rails_env} -D"
      else
        logger.important("Config file for \"#{unicorn_env}\" environment was not found at \"#{config_path}\"", "Unicorn")
      end
    end
  end
end
