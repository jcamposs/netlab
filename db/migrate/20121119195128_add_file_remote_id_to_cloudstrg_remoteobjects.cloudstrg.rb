# This migration comes from cloudstrg (originally 20121119184135)
class AddFileRemoteIdToCloudstrgRemoteobjects < ActiveRecord::Migration
  def change
    add_column :cloudstrg_remoteobjects, :file_remote_id, :integer
  end
end
