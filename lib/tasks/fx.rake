namespace :fx do
  desc "Reset the fx application environment"
  task :reset => :environment do
    Rake::Task["db:migrate:reset"].invoke
    Rake::Task["db:fixtures:load"].invoke
  end
end