# This migration comes from cloudstrg (originally 20121119105425)
class RenameCloudstrgRemoteobjectPluginIdToCloudstrgRemoteobjectCloudstrgpluginId < ActiveRecord::Migration
  def change
    rename_column :cloudstrg_remoteobjects, :plugin_id, :cloudstrgplugin_id
  end
end
