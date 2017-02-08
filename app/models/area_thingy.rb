class AreaThingy
	include Mongoid::Document
	include Mongoid::Timestamps
	belongs_to :user, index: true
	belongs_to :area, index: true
	field :first_coord_time_stamp, type: DateTime
	field :last_coord_time_stamp, type: DateTime
	field :done, type: Boolean, default: false
	field :visit, type: Boolean, default: false
end