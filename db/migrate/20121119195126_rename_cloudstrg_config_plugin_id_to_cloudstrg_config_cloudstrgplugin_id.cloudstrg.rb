# This migration comes from cloudstrg (originally 20121116111055)
class RenameCloudstrgConfigPluginIdToCloudstrgConfigCloudstrgpluginId < ActiveRecord::Migration
  def change
    rename_column :cloudstrg_configs, :plugin_id, :cloudstrgplugin_id
  end
end
