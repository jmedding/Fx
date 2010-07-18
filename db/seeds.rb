# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
#fill the exposures with dummy data
Currency.all.delete	#get rid of any dummy currencies used in the test fixtures
Currency.create(:symbol => 'EUR', :description => 'Euro', :base => true)
Currency.create(:symbol => 'USD', :description => 'US Dollar', :base => false)
Currency.create(:symbol => 'CHF', :description => 'Swiss Franc')
Currency.create(:symbol => 'THB', :description => 'Thai Bhat' )
Currency.create(:symbol => 'CNY', :description => 'Chinese Yuan')
#~ Currency.create(:symbol => 'INR', :description => 'Indian Rupee')
#~ Currency.create(:symbol => 'ILS', :description => 'Isreal Sheckel')
#~ Currency.create(:symbol => 'RUB', :description => 'Russian Ruble')
#~ Currency.create(:symbol => 'CAD', :description => 'Canadain Dollar')
#~ Currency.create(:symbol => 'MXN', :description => 'Mexican Peso')
#~ Currency.create(:symbol => 'JPY', :description => 'Japanese Yen')
#~ Currency.create(:symbol => 'GBP', :description => 'British Pound')
#~ Currency.create(:symbol => 'SEK', :description => 'Swedish Kroner')
#~ Currency.create(:symbol => 'AED', :description => 'UAE Dirham')
#~ Currency.create(:symbol => 'SAR', :description => 'Saudi Riyal')
#~ Currency.create(:symbol => 'AUD', :description => 'Australian Dollar')
#~ Currency.create(:symbol => 'NZD', :description => 'New Zealand Dollar')
#~ Currency.create(:symbol => 'RON', :description => 'Romanian New Lei')
#~ Currency.create(:symbol => 'HUF', :description => 'Hungarian Forint')
#~ Currency.create(:symbol => 'PLN', :description => 'Polish Zlotych')
#~ Currency.create(:symbol => 'BRL', :description => 'Brazilian Real')
#~ Currency.create(:symbol => 'VEF', :description => 'Venezuelan Fuerte')
#~ Currency.create(:symbol => 'PEN', :description => 'Peru Neuvos Sole')
#~ Currency.create(:symbol => 'ZAR', :description => 'S. African Rand')
#~ Currency.create(:symbol => 'KES', :description => 'Kenya Shilling')
#~ Currency.create(:symbol => 'KRW', :description => 'S. Korean Won')
#~ Currency.create(:symbol => 'IQD', :description => 'Iraq Dinar')
#~ Currency.create(:symbol => 'EGP', :description => 'Egyptian Pound')
#~ Currency.create(:symbol => 'HRK', :description => 'Croatian Kuna')

Conversion.generate_conversions!

Exposure.populate_exposures!

['user', 'admin', 'root'].each_with_index do |level, i|
	Level.create(:name => level, :step => i+1)
	puts "creating Level: " + level
end

#add all node groups from fixtures to base
Group.rebuild!
base = Group.create(	:name => 'Base')
Group.all.each do |g|
	 if (g.root? && g != base)
		g.move_to_child_of(base)
		puts "Moving #{g.name} to BASE"
	end
end
base.reload

#root = User.create(	:name => "Rooter", 
#									:login => "rooter",
#									:password => 'rooty',
#									:email => 'jonmedding@gmail.com')
#puts "User #{root.login} created"
	
Priviledge.create(	:user => User.find_by_login('root'),
								:group => base,
								:level_id => 3)	# 3 => root
								
						
#rake db:seed