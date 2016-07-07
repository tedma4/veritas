class User
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :name, :type => String, index: true
  field :user_name, :type => String
  field :current_location, type: Geo::Point, index: true

  def self.find_users_from_circle(current_user)
		NoBrainer.run { |r| circle1 = r.circle(current_user.current_location, 10, {:unit => 'mi'})
										r.table('users').get_intersecting(circle1, {:index => 'current_location'}).run(conn) }
  end
end

def add_location_to_users_and_images
	Image.each do |image|
		sample_location = (-180..180).to_a.sample(2)
		image.update_attributes(location: sample_location )
	end

	User.each do |user| 
		sample_location = (-180..180).to_a.sample(2)
		user.update_attribute	s(current_location: sample_location )
	end
end

# images = r.db('veritas_development');
# images.table('images');
# var use = r.db('veritas_development').table('users');
# use
  
  


# var database = r.db('veritas_development').table('users').limit(1);


# var secretBase = r.point(-122.422876,37.777128);
# r.table('hideouts').getNearest(secretBase,{index: 'location', maxResults: 25}
# ).
# var database = r.db('veritas_development').table('users').get('3YxPL0X8jlUFqY')('current_location')('latitude');

# var circle1 = r.db('veritas_development').table('users').get('3YxPL0X8jlUFqY')('current_location');
# r.db('veritas_development').table('users').getNearest(circle1,{index: 'current_location', maxResults: 234});

# r.table('users').getIntersecting(circle1, {index: 'current_location'}).run(conn)  

# var circle1 = r.circle(r.db('veritas_development').table('users').get('3YxPL0X8jlUFqY')('current_location'), 1000, {unit: 'mi'});

# r.db('veritas_development').table('users').filter(r.row('current_location').intersects(circle1))