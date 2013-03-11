class CreateWorkspaceInvitations < ActiveRecord::Migration
  def change
    create_table :workspace_invitations do |t|
      t.integer :user_id
      t.integer :workspace_id

      t.timestamps
    end
  end
end
