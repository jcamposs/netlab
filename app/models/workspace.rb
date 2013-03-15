class Workspace < ActiveRecord::Base
  belongs_to :scene
  belongs_to :user
  has_and_belongs_to_many :editors, :class_name => User
  has_many :virtual_machines, dependent: :destroy
  has_many :collision_domains, dependent: :destroy
  has_many :workspace_invitations, dependent: :destroy

  validates :user_id, :scene_id, :name, presence: true
  
  attr_accessor :share_ids, :unshare_ids, :session

  after_save :invite_editors
  before_destroy :unshare_editors

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
            begin
              plugin = self.user.cloudstrgconfig.cloudstrgplugin
              session = {} if not session
              _params = {:user => self.user,
                       :plugin_id => plugin,
                       :redirect => "https://netlab.libresoft.es/workspaces",
                       :file_id => self.scene.remote.file_remote_id,
                       :local_file_id => self.scene.remote.id,
                       :user_id => user.id,
                       :session => session}

              driver = CloudStrg.new_driver _params
              _session, url = driver.config _params
              session.merge!(_session)
              if not url
                driver.unshare_file _params
              end
            rescue Exception => e
              p 'Exception'
            end
          end
          inv = user.workspace_invitations.find_by_workspace_id(self.id)
          if inv
            inv.destroy
          end
        end
      end
    end

  private 
  def unshare_editors
    self.editors.each do |editor|
      begin
        plugin = self.user.cloudstrgconfig.cloudstrgplugin
        session = {} if not session
        _params = {:user => self.user,
               :plugin_id => plugin,
               :redirect => "https://netlab.libresoft.es/workspaces",
               :file_id => self.scene.remote.file_remote_id,
               :local_file_id => self.scene.remote.id,
               :user_id => editor.id,
               :session => session}

        driver = CloudStrg.new_driver _params
        _session, url = driver.config _params
        session.merge!(_session)
        if not url
          driver.unshare_file _params
        end
      rescue Exception => e
        p 'Exception'
      end
    end
  end
end
