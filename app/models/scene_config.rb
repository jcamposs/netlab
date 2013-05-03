class SceneConfig < ActiveRecord::Base
  attr_accessible :name, :remoteobject_id, :user_id, :workspace_id, :url

  belongs_to :user
  belongs_to :workspace
  belongs_to :remote, :class_name => Cloudstrg::Remoteobject, :dependent => :destroy

end
