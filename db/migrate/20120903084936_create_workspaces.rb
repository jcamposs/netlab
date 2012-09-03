class CreateWorkspaces < ActiveRecord::Migration
  def change
    create_table :workspaces do |t|
      t.integer :user_id
      t.integer :scene_id
      t.string :proxy

      t.timestamps
    end
  end
end
