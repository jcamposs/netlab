class CreateUsersWorkspaces < ActiveRecord::Migration
  def change
    create_table :users_workspaces, :id => false  do |t|
      t.references :user
      t.references :workspace
    end
    add_index :users_workspaces, [:user_id, :workspace_id]
    add_index :users_workspaces, [:workspace_id, :user_id]
  end
end
