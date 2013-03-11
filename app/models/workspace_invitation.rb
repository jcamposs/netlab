class WorkspaceInvitation < ActiveRecord::Base
  attr_accessible :user_id, :workspace_id

  belongs_to :workspace
  belongs_to :user
end
