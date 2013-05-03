class Workspace < ActiveRecord::Base
  belongs_to :scene
  belongs_to :user
  has_and_belongs_to_many :editors, :class_name => User
  has_many :virtual_machines, dependent: :destroy
  has_many :collision_domains, dependent: :destroy
  has_many :workspace_invitations, dependent: :destroy
  has_many :workspace_tasks, dependent: :destroy
  has_one :scene_config, dependent: :destroy

  validates :user_id, :scene_id, :name, presence: true
  
  attr_accessor :share_ids, :unshare_ids, :session, :config_file

  after_save :invite_editors, :set_config_file
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
  def set_config_file
    if config_file
      self.scene_config.destroy if self.scene_config
      ## SAVE FILE
      name = config_file.original_filename
      p "Saving file #{name}"
      directory = Rails.root.join('public', 'uploads')
      # create the file path
      path = File.join(directory,"#{rand(1000000000)}_#{name}")
      # write the file
      File.open(path, "wb") { |f| f.write(config_file.read)}

      ## UPLOAD FILE
      begin
        plugin = self.user.cloudstrgconfig.cloudstrgplugin
        p "Uploading file #{name} to #{plugin.plugin_name}"
        session = {} if not session
        _params = {:user => self.user,
                   :plugin_id => plugin,
                   :redirect => "https://netlab.libresoft.es/workspaces",
                   :file => File.open(path, "rb"),
                   :filename => name,
                   :mimetype => 'application/x-gzip',
                   :session => session}

        driver = CloudStrg.new_driver _params
        _session, url = driver.config _params
        session.merge!(_session)
        if not url
          ro = driver.create_generic_file _params


          ## Creating scene config object in local database
          p "Creating scene config object for file #{name}"
          sc = self.build_scene_config(:user_id => self.user, :name => name)
          sc.remote = Cloudstrg::Remoteobject.find(ro.id)
          sc.save

          ## SET PERMISSIONS
          p "Making file #{name} public"
          _params = {:file_id => sc.remote.file_remote_id,
                     :local_file_id => ro.id,
                     :user_id => self.user.id}
          p _params
          m_url = driver.share_public_file _params
          if m_url
            sc.url = m_url 
            sc.save
          end
        end
      rescue Exception => e
        p "Exception: #{e}"
      end


      ## REMOVE LOCAL FILE
      p "Remove local file #{name}"
      File.delete(path)
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
