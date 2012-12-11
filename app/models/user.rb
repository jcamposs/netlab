class User < ActiveRecord::Base
  has_many :scenes, dependent: :destroy
  has_many :workspaces
  has_many :shellinaboxes
  has_many :netlabsessions, dependent: :destroy

  # Cloud storage params
  has_one :cloudstrgconfig, :class_name => Cloudstrg::Config, :dependent => :destroy
  has_one :dropboxstrgparams, :class_name => Dropboxstrg::Param, :dependent => :destroy
  has_one :gdrivestrgparams, :class_name => Gdrivestrg::Param, :dependent => :destroy
  ###

  validates :first_name, :last_name, presence: true

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :first_name, :last_name
end
