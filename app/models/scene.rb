class Scene < ActiveRecord::Base
  validates :name, presence: true
end
