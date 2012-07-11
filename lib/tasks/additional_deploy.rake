namespace :db do
  # TODO: It's not good when we save password in repository, but...
  # Good when we create rake task for create dump and execute this task remotely,
  # but I am lazy...
  desc 'Load database from production server'
  task :load_from_server => :environment do
    tmp_file = "/tmp/bp-#{rand(99999).to_s}.sql.gz"
    %x(ssh rvm_user@bright-people.ru "pg_dump -U postgres bp_production | gzip -9" > #{tmp_file})

    Rake::Task['db:drop'].execute
    Rake::Task['db:create'].execute
    config = ActiveRecord::Base.configurations[Rails.env]

    puts "Then execute following"
    unless config['password'].present?
      %x(zcat #{tmp_file} | psql -U #{config['username']} #{config['database']} && rm -rf #{tmp_file})
    else
      puts "zcat #{tmp_file} | psql -U #{config['username']} #{config['database']} && rm -rf #{tmp_file}"
    end
  end
end

namespace :images do
  task :load_from_server do
    tmp_file = "/tmp/bp-images-#{rand(99999).to_s}.tar.gz"
    %x(rm -rf /var/www/bright-people/shared/system)
    %x(ssh rvm_user@bright-people.ru "cd /var/www/bright-people/shared && tar czf - system" > #{tmp_file})
    %x(cd /var/www/bright-people/shared && tar xvf #{tmp_file})
  end
end