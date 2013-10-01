class CreateChatInvitations < ActiveRecord::Migration
  def change
    create_table :chat_invitations do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.string :url

      t.timestamps
    end
  end
end