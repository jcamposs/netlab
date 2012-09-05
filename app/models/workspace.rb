class Workspace < ActiveRecord::Base
  belongs_to :scene
  belongs_to :user
  has_many :virtual_machines, dependent: :destroy

  validates :user_id, :scene_id, :name, presence: true
end
