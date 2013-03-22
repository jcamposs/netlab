class CreateWorkspaceTasks < ActiveRecord::Migration
  def change
    create_table :workspace_tasks do |t|
      t.integer :author_id
      t.integer :assigned_id
      t.integer :workspace_id
      t.integer :state
      t.integer :priority
      t.string :subject
      t.text :description
      t.string :auto_task

      t.timestamps
    end
  end
end
