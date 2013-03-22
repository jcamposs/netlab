class WorkspaceTask < ActiveRecord::Base
  attr_accessible :assigned_id, :author_id, :workspace_id, :auto_task, :description, :priority, :state, :subject

  belongs_to :author, :class_name => User, :foreign_key => :author_id
  belongs_to :assigned, :class_name => User, :foreign_key => :assigned_id

  belongs_to :workspace

  validates :priority, :inclusion => 0..5
  validates :state, :inclusion => 0..5
end
