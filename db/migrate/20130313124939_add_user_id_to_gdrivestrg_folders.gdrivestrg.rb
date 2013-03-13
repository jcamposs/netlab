# This migration comes from gdrivestrg (originally 20130313124441)
class AddUserIdToGdrivestrgFolders < ActiveRecord::Migration
  def change
    add_column :gdrivestrg_folders, :user_id, :integer
  end
end
