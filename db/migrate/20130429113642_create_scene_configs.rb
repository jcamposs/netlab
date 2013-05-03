class CreateSceneConfigs < ActiveRecord::Migration
  def change
    create_table :scene_configs do |t|
      t.integer :workspace_id
      t.integer :remoteobject_id
      t.integer :user_id
      t.string :name

      t.timestamps
    end
  end
end
