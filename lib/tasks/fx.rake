namespace :fx do
  desc "Reset the fx application environment"
  task :reset => :environment do
    Rake::Task["db:migrate:reset"].invoke
	 #Rake::Task["db:seed"].invoke	#Running this task here doesn't work.  db levels is empty...
    
	 #have to make db:seed run without fixtures for production setup.
	 
	p "Rails environement = " + RAILS_ENV  
	 Rake::Task['db:fixtures:load'].invoke unless RAILS_ENV == 'production'
	 Rake::Task["db:seed"].invoke
 end
 
 desc "Update the conversions and exposures with the lates data"
 task :daily_update => :environment do
	 Conversion.update!
	 Exposure.populate_exposures!
 end
end