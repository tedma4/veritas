class User
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :name, :type => String, index: true
  field :user_name, :type => String
end
