class DropDropboxparamsTable < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.table_exists? 'dropboxstrg_params'
      drop_table :dropboxstrg_params
    end
    plugin = Cloudstrg::Cloudstrgplugin.find_by_plugin_name("dropbox")
    if plugin
      plugin.destroy
    end
  end

  def down
  end
end
