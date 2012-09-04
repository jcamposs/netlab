class AddNameToWorkspaces < ActiveRecord::Migration
  def change
    add_column :workspaces, :name, :string

  end
end
