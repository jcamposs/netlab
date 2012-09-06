class VirtualMachine < ActiveRecord::Base
  belongs_to :workspace
  has_many :interfaces, dependent: :destroy
end
