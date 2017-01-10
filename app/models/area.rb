class Area
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Geospatial
  include Mongoid::Tree
  # has_many :locations

  # field :area_polygon, type: Polygon
  # spatial_index :area_polygon

  # field :area_circle, type: Point
  # spatial_index :area_circle
  # field :radius, type: Float
  # field :area_type, type: String

  # field :title, type: String, default: "public"
  # validates :user_id, presence: true

end