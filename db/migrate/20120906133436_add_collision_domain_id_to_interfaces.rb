class AddCollisionDomainIdToInterfaces < ActiveRecord::Migration
  def change
    add_column :interfaces, :collision_domain_id, :integer

  end
end
