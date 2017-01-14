class Area
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Geospatial
  include Mongoid::Tree

  field :area_profile, type: Polygon, sphere: true

  field :title, type: String, default: "public"

  # before_destroy :update_tree
  # before_save :find_ancestor

  private
  def find_ancestor
    Area.intersects_polygon(area_profile)
  end

  # def update_tree

  # end
end