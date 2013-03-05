class Workspace < ActiveRecord::Base
  belongs_to :scene
  belongs_to :user
  has_and_belongs_to_many :editors, :class_name => User
  has_many :virtual_machines, dependent: :destroy
  has_many :collision_domains, dependent: :destroy

  validates :user_id, :scene_id, :name, presence: true
  
  attr_accessor :share_ids
  before_save :fill_share

  private 
    def fill_share
      #if not share_ids
      #  return false
      #end
      #self.editors << self.user
      if share_ids
        p share_ids
      end
      
      
    end
end
