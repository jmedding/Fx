# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
#fill the exposures with dummy data

Currency.delete_all	unless Currency.all.empty? #get rid of any dummy currencies used in the test fixtures

eur = Currency.create(:symbol => 'EUR', :description => 'Euro', :base => true)
usd = Currency.create(:symbol => 'USD', :description => 'US Dollar')
chf = Currency.create(:symbol => 'CHF', :description => 'Swiss Franc')
thb = Currency.create(:symbol => 'THB', :description => 'Thai Bhat')
cny = Currency.create(:symbol => 'CNY', :description => 'Chinese Yuan')

if RAILS_ENV == 'production'
	Currency.create(:symbol => 'INR', :description => 'Indian Rupee')
	Currency.create(:symbol => 'ILS', :description => 'Isreal Sheckel')
	Currency.create(:symbol => 'RUB', :description => 'Russian Ruble')
	Currency.create(:symbol => 'CAD', :description => 'Canadain Dollar')
	Currency.create(:symbol => 'MXN', :description => 'Mexican Peso')
	Currency.create(:symbol => 'JPY', :description => 'Japanese Yen', :base => true )
	Currency.create(:symbol => 'GBP', :description => 'British Pound', :base => true )
	Currency.create(:symbol => 'SEK', :description => 'Swedish Kroner', :base => true )
	Currency.create(:symbol => 'AED', :description => 'UAE Dirham')
	Currency.create(:symbol => 'SAR', :description => 'Saudi Riyal')
	Currency.create(:symbol => 'AUD', :description => 'Australian Dollar', :base => true )
	Currency.create(:symbol => 'NZD', :description => 'New Zealand Dollar')
	Currency.create(:symbol => 'RON', :description => 'Romanian New Lei')
	Currency.create(:symbol => 'HUF', :description => 'Hungarian Forint')
	Currency.create(:symbol => 'PLN', :description => 'Polish Zlotych', :base => true )
	Currency.create(:symbol => 'BRL', :description => 'Brazilian Real')
	Currency.create(:symbol => 'VEF', :description => 'Venezuelan Fuerte')
	Currency.create(:symbol => 'PEN', :description => 'Peru Neuvos Sole')
	Currency.create(:symbol => 'ZAR', :description => 'S. African Rand')
	Currency.create(:symbol => 'KES', :description => 'Kenya Shilling')
	Currency.create(:symbol => 'KRW', :description => 'S. Korean Won')
	Currency.create(:symbol => 'IQD', :description => 'Iraq Dinar')
	Currency.create(:symbol => 'EGP', :description => 'Egyptian Pound')
	Currency.create(:symbol => 'HRK', :description => 'Croatian Kuna')
end

Conversion.generate_conversions!

['user', 'admin', 'root'].each_with_index do |level, i|
	Level.create(:name => level, :step => i+1)
	puts "creating Level: " + level
end

demo_account = Account.create( 	:currency => eur,
																:payment => 10.0,
																:period => 1) #month
puts "demo_account created: " + demo_account.save!.to_s
root_account = Account.create( 	:currency => eur,
																:payment => 0.0,
																:period => 1) #month
puts "root_account created: " + root_account.save!.to_s

#add all node groups from fixtures to base
Group.rebuild!
base = Group.create(	:name => 'Base', :account => root_account)
puts "base group created: " + base.save!.to_s
demo_group = Group.create(:name => 'Demo Group', :account => demo_account)
puts "demo_group created: " + demo_group.save!.to_s

Group.all.each do |g|
	 if (g.root? && g != base)
		g.move_to_child_of(base)
		puts "Moving #{g.name} to BASE"
	end
end
base.reload


root = User.create(	:name => "Base", 
									:login => "base",
									:password => 'basic',
									:password_confirmation => 'basic',
									:email => 'jonmedding@gmail.com',
									:account => root_account)
puts "base saved: " + root.save!.to_s



demo_user = User.create(	:name => "Demo", 
									:login => "demo",
									:password => 'demofx',
									:password_confirmation => 'demofx',
									:email => 'demo@gmail.com',
									:account => demo_account)
puts "demo_user saved: " + demo_user.save!.to_s
	
Priviledge.create(	:user => root,
								:group => base,
								:level_id => 3)	# 3 => root
Priviledge.create(	:user => demo_user,
								:group => demo_group,
								:level_id => 1)	# 1 => user								

demo_project = Project.create(	:user => demo_user,
															:name => "Demo Project",
															:description => 'A Demo Project to explain the app',
															:chance => 0.6)
puts "demo_project saved: " + demo_project.save!.to_s															
demo_tender = Tender.create( 	:project => demo_project,
															:bid_date => Date.today + 30,
															:validity => Date.today + 180,
															:user => demo_user,
															:description => 'Demo Tender',
															:group => demo_group)
puts "demo_tender saved: " + demo_tender.save!.to_s
demo_exposure1 = Exposure.create(	:currency_in => eur.id,
																	:currency_out => usd.id,
																	:amount => 1000000,
																	:tender => demo_tender,
																	:supply => false)
puts "demo_exposure1 saved: " + demo_exposure1.save!.to_s
demo_exposure2 = Exposure.create(	:currency_in => thb.id,
																	:currency_out => eur.id,
																	:amount => 20000000,
																	:tender => demo_tender,
																	:supply => true)
puts "demo_exposure2 saved: " + demo_exposure2.save!.to_s	

if  RAILS_ENV == 'test'
	Exposure.populate_exposures!  # need this to populate exposure from fixtures (not needed in production).
end
#rake db:seed
