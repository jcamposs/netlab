class Workspace < ActiveRecord::Base
  belongs_to :scene
  belongs_to :user
end
