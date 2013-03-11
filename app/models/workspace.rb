class Workspace < ActiveRecord::Base
  belongs_to :scene
  belongs_to :user
  has_and_belongs_to_many :editors, :class_name => User
  has_many :virtual_machines, dependent: :destroy
  has_many :collision_domains, dependent: :destroy
  has_many :workspace_invitations

  validates :user_id, :scene_id, :name, presence: true
  
  attr_accessor :share_ids, :unshare_ids

  after_save :invite_editors

  private 
    def invite_editors
      if share_ids
        User.find(share_ids.gsub('_', '').split(',')).each do |user|
          #self.editors << user
          if not self.editors.include?(user)
            inv = user.workspace_invitations.find_by_workspace_id(self.id)
            if not inv
              inv = user.workspace_invitations.build(:workspace_id => self.id)
              inv.save
            end
          end
        end
      end
      if unshare_ids
        User.find(unshare_ids.gsub('_', '').split(',')).each do |user|
          #self.editors << user
          if self.editors.include? user
	    self.editors.delete(user)
          end
          inv = user.workspace_invitations.find_by_workspace_id(self.id)
          if inv
            inv.destroy
          end
        end
      end
    end
end
