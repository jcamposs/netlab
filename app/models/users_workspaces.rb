class UsersWorkspaces < ActiveRecord::Base
  attr_accessible :user_id, :workspace_id
end
