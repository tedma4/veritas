class AreaObserver
	include Mongoid::Document
	include Mongoid::Timestamps
	belongs_to :user, index: true, counter_cache: true
	belongs_to :area, index: true, counter_cache: true
	# field :time, type: Integer
	field :first_coord_time_stamp, type: DateTime
	field :last_coord_time_stamp, type: DateTime
end