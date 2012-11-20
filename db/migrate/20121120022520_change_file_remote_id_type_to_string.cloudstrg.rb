# This migration comes from cloudstrg (originally 20121120022309)
class ChangeFileRemoteIdTypeToString < ActiveRecord::Migration
  def change
    change_column :cloudstrg_remoteobjects, :file_remote_id, :string

  end
end
