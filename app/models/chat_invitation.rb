class ChatInvitation < ActiveRecord::Base
  attr_accessible :sender_id, :receiver_id, :workspace_id, :url

  belongs_to :sender, :class_name => User, :foreign_key => :sender_id
  belongs_to :receiver, :class_name => User, :foreign_key => :receiver_id
  
  validates :receiver_id, :presence => true
  validates :url, :presence => true
end