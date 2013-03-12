class RemoveUnusedColumnsToUser < ActiveRecord::Migration
  def up
    remove_column :users, :reset_password_token, :reset_password_sent_at, 
                          :confirmation_token, :confirmed_at, :confirmation_sent_at, :unconfirmed_email
  end

  def down
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at , :datetime
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string
  end
end
