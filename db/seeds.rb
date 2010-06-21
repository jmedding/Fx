# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
#fill the exposures with dummy data
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