class AddIpToInterfaces < ActiveRecord::Migration
  def change
    add_column :interfaces, :ip, :string, :default => nil
  end
end
