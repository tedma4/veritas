class Area
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Geospatial

  field :area_profile, type: Polygon, sphere: true

  field :title, type: String, default: "Name of Area"
  field :level, type: String, default: "l3"
  has_many :area_observers
  has_many :area_thingies
  private

  def self.profile_maker(area_profile)
    # if the area_profile is a polygon
    saved_hash = {type: "Polygon"}
    if area_profile.count > 2
      shape = area_profile.map{|coords| coords.split(",").map(&:to_f).reverse}
      shape << shape.first
      saved_hash[:coordinates] = [shape]
    else
      # if the area_profile is a rectangle
      north = area_profile.first.split(",").map(&:to_f)
      northWest = {lat: north.first, lng: north.last}
      south = area_profile.last.split(",").map(&:to_f)
      southEast = {lat: south.first, lng: south.last}
      northEast = {lat: northWest[:lat], lng: southEast[:lng] }
      southWest = {lat: southEast[:lat], lng: northWest[:lng] }

      # northWest, southWest, southEast, northEast, northWest
      shape = [
        [northWest[:lng], northWest[:lat]], 
        [southWest[:lng], southWest[:lat]], 
        [southEast[:lng], southEast[:lat]], 
        [northEast[:lng], northEast[:lat]], 
        [northWest[:lng], northWest[:lat]]
      ]
      saved_hash[:coordinates] = [shape]
    end
    return saved_hash
  end
end