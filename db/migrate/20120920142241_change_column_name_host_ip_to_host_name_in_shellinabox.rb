class ChangeColumnNameHostIpToHostNameInShellinabox < ActiveRecord::Migration
  def up
    rename_column :shellinaboxes, :host_ip, :host_name
  end

  def down
    rename_column :shellinaboxes, :host_name, :host_ip
  end
end
