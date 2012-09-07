class AddWorkspaceIdToCollisionDomains < ActiveRecord::Migration
  def change
    add_column :collision_domains, :workspace_id, :integer

  end
end
