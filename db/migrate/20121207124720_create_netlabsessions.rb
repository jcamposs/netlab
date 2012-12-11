class CreateNetlabsessions < ActiveRecord::Migration
  def change
    create_table :netlabsessions do |t|
      t.integer :user_id
      t.string :session_id
      t.text :params

      t.timestamps
    end
  end
end
