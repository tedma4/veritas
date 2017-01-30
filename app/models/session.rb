class Session
	include Mongoid::Document
	include Mongoid::Timestamps
	belongs_to :user, index: true

end