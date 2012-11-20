class AddRemoteIdToScenes < ActiveRecord::Migration
  def change
    add_column :scenes, :remote_id, :integer

  end
end
