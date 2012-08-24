class RenameOwnerIdToUserIdInScenes < ActiveRecord::Migration
  def up
    rename_column :scenes, :owner_id, :user_id
  end

  def down
    rename_column :scenes, :user_id, :owner_id
  end
end
