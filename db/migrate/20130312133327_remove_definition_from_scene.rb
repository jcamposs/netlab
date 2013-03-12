class RemoveDefinitionFromScene < ActiveRecord::Migration
  def up
    remove_column :scenes, :definition
  end

  def down
    add_column :scenes, :definition, :text
  end
end
