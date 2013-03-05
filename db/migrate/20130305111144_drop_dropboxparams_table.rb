class DropDropboxparamsTable < ActiveRecord::Migration
  def up
    drop_table :dropboxstrg_params
    plugin = Cloudstrg::Cloudstrgplugin.find_by_plugin_name("dropbox")
    if plugin
      plugin.destroy
    end
  end

  def down
  end
end
