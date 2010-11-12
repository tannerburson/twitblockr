task :start do
  sh "thin -p 4567 -D -R config.ru start"
end

task :start_beanstalkd do
  sh "beanstalkd -d"
end

task :shotgun do
  sh "shotgun -p 4567 -s thin config.ru"
end

task :test do
  fl = Dir['test/**/test_*.rb']
  sh "specrb -I test/ " << fl.join(" ")
end

task :worker do
  sh "ruby lib/worker.rb"
end

task :todo do
  sh "grep -nr '#TODO' *"
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |rcov|
	rcov.libs << 'test'
	rcov.pattern = 'tests/**/test*.rb'
	rcov.rcov_opts << '--no-html --exclude test_.*'
	rcov.verbose = true
end

task :deploy => :test do
  sh "./script/deploy"
end

task :vendor_setup do
  sh "git submodule init && git submodule update"
end

task :vendor_update do
  sh "cd ../ && git submodule update && cd -"
  Dir['vendor/*'].each do |d| 
	sh "cd #{d} && git pull origin master && cd -" unless d.include? '.'
  end
end

namespace :db do
  task :create_dir do
	unless File.exists? 'db'
	  FileUtils.mkdir_p('db')
	end
  end

  task :upgrade => :create_dir do
	require 'app'
	DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/twitblockr.sqlite3")
	DataMapper.auto_upgrade!
  end

  task :schema => :create_dir do
	require 'app'
	if File.exists? 'db/markit.sqlite3'
	  FileUtils.rm('db/markit.sqlite3')
	end
	DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/twitblockr.sqlite3")
	DataMapper.auto_upgrade!
  end
end
