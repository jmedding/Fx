namespace :fx do
  desc "Reset the fx application environment"
  task :reset => :environment do
    Rake::Task["db:migrate:reset"].invoke
	 #Rake::Task["db:seed"].invoke	#Running this task here doesn't work.  db levels is empty...
    Rake::Task['db:fixtures:load'].invoke
	 Rake::Task["db:seed"].invoke
  end
end