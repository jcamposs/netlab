
require 'cloudstrg/cloudstrg'


class Scene < ActiveRecord::Base
  belongs_to :user
  has_many :workspaces, dependent: :destroy

  validates :name, presence: true
  
  belongs_to :remote, :class_name => Cloudstrg::Remoteobject, :dependent => :destroy


  attr_accessor :redirection_url
  attr_accessor :session
  attr_accessor :file_content

  before_save :create_remoteobject
  before_destroy :remove_remoteobject
  #before_update_attributes :update_remoteobject

  private 
    def create_remoteobject
      if self.remote
        _plugin = self.remote.cloudstrgplugin
      else
         raise CloudStrg::RONotConfigured, 'You must select the remote object driver before saving a file.' if not self.user.cloudstrgconfig
         _plugin = self.user.cloudstrgconfig.cloudstrgplugin
      end
      
      params = {:user => self.user, :plugin_id => _plugin, :redirect => redirection_url, :session => session}
      driver = CloudStrg.new_driver params
      session, url = driver.config params
      raise CloudStrg::ROValidationRequired, url if url

      params[:filename] = self.name
      params[:file_content] = self.definition
      self.definition = ""
      if self.remote
        params[:fileid] = self.remote.file_remote_id
        ro_id = driver.update_file params
      else
        ro_id = driver.create_file params
        self.remote = Cloudstrg::Remoteobject.find(ro_id)
      end

      if not self.remote
        return false
      end
    end

    def remove_remoteobject
      if self.remote
        _plugin = self.remote.cloudstrgplugin
      else
         raise CloudStrg::RONotConfigured, 'You must select the remote object driver before saving a file.' if not self.user.cloudstrgconfig
         _plugin = self.user.cloudstrgconfig.cloudstrgplugin
      end
      
      params = {:user => self.user, :plugin_id => _plugin, :redirect => redirection_url, :session => session}
      driver = CloudStrg.new_driver params
      session, url = driver.config params
      raise CloudStrg::ROValidationRequired, url if url

      if self.remote
        params[:fileid] = self.remote.file_remote_id
        driver.remove_file params
      end
    end

end
