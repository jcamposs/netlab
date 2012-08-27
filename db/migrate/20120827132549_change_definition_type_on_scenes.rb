class ChangeDefinitionTypeOnScenes < ActiveRecord::Migration
  def up
    change_column :scenes, :definition, :text, :limit => nil
  end

  def down
    change_column :scenes, :definition, :string
  end
end
