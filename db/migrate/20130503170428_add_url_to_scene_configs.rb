class AddUrlToSceneConfigs < ActiveRecord::Migration
  def change
    add_column :scene_configs, :url, :string
  end
end
