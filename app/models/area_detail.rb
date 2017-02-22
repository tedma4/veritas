# class AreaDetail
# 	include Mongoid::Document
# 	embedded_in :areas
# 	# Description - Description(AreaDetail)
# 	field :description, type: String
# 	# Place type (Restaurant, Shopping Center, Convenience Store, Etc ), Etc - PlaceDetail(AreaDetail)
# 	field :place_detail, type: Array, default: Array.new
# 	# Address - Address(AreaDetail)
# 	field :address, type: String
# 	# Link to website - Website(AreaDetail)
# 	field :website, type: String
# 	# Phone Number - PhoneNumber(AreaDetail)
# 	field :phone_number, type: String
# 	# Potential special things(Open Hours, Happy hour info, menu, specials and discounts, Etc) - SpecialInfo(AreaDetail)
# 	field :special_info, type: Hash, default: Hash.new
# 	# Label - Labels(AreaDetail)
# 	field :label, type: Array, default: Array.new
# end