# This migration comes from cloudstrg (originally 20121109175154)
class CreateCloudstrgRemoteobjects < ActiveRecord::Migration
  def change
    create_table :cloudstrg_remoteobjects do |t|
      t.integer "#{Cloudstrg.user_class.downcase}_id".to_sym
      t.integer :plugin_id
      t.string :filename
      t.string :filehash

      t.timestamps
    end
  end
end
