namespace :fx do
  desc "Reset the fx application environment"
  task :reset => :environment do
    Rake::Task["db:migrate:reset"].invoke
    #it seems that if you rund db:fixtures:load it deletes any existing seed data...
	 #have to make db:seed run without fixtures for production setup.
	 
	p "Rails environement = " + RAILS_ENV  
	 Rake::Task["db:seed"].invoke 
	 #decision is to use db:seed to create all data for test and production environments.
	 #Rake::Task['db:fixtures:load'].invoke unless RAILS_ENV == 'production'	 
 end
 
 desc "Update the conversions and exposures with the latest data"
 task :daily_update => :environment do
	 Conversion.update!
	 Exposure.populate_exposures!
 end
end
