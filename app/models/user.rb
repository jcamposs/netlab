class User < ActiveRecord::Base
  has_many :scenes, dependent: :destroy
  has_many :workspaces
  has_many :shellinaboxes
  has_many :netlabsessions, dependent: :destroy
  has_and_belongs_to_many :editorworkspaces, :class_name => Workspace
  has_many :workspace_invitations, dependent: :destroy

  has_many :author_workspace_tasks, class_name: WorkspaceTask, foreign_key: :author_id, dependent: :destroy
  has_many :assigned_workspace_tasks, class_name: WorkspaceTask, foreign_key: :assigned_id, dependent: :destroy
  
  has_many :receiver_chat_invitations, class_name: ChatInvitation, foreign_key: :receiver_id, dependent: :destroy

  # Cloud storage params
  has_one :cloudstrgconfig, :class_name => Cloudstrg::Config, :dependent => :destroy
  has_one :gdrivestrgparams, :class_name => Gdrivestrg::Param, :dependent => :destroy
  has_one :gdrivestrgfolder, :class_name => Gdrivestrg::Folder, :dependent => :destroy
  has_many :gdrivestrgpermissions, :class_name => Gdrivestrg::PermissionId, :dependent => :destroy
  ###

  validates :first_name, :last_name, presence: true

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :trackable, :omniauthable, :omniauth_providers => [:google_oauth2]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :remember_me,
    :first_name, :last_name

  def full_name
    return "#{self.first_name} #{self.last_name}"
  end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:email => data["email"]).first

    unless user
      user = User.create(email: data["email"],
                           first_name: data["first_name"],
                           last_name: data["last_name"]
	    		   #password: Devise.friendly_token[0,20]
	    		  )
    end
    unless user.cloudstrgconfig
      config = user.build_cloudstrgconfig
      config.cloudstrgplugin_id = Cloudstrg::Cloudstrgplugin.find_by_plugin_name("gdrive").id
      config.save
    end
    user.save
    user
  end

end
