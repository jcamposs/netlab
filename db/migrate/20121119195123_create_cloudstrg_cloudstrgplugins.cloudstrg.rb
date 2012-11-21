# This migration comes from cloudstrg (originally 20121105173015)
class CreateCloudstrgCloudstrgplugins < ActiveRecord::Migration
  def change
    create_table :cloudstrg_cloudstrgplugins do |t|
      t.string :plugin_name
      t.string :version

      t.timestamps
    end
  end
end
