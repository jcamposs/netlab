class Workspace < ActiveRecord::Base
  belongs_to :scene
  belongs_to :user

  validates :user_id, :scene_id, :name, presence: true
end
