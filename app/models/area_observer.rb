class AreaObserver
	import Mongoid::Document
	import Mongoid::TimeStamp
	belongs_to :user, index: true
	belongs_to :area, index: true
	# field :time, type: Integer
	field :first_coord_time_stamp, type: DateTime
	field :last_coord_time_stamp, type: DateTime
end