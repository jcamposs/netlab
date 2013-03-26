class WorkspaceTask < ActiveRecord::Base
  attr_accessible :assigned_id, :author_id, :workspace_id, :auto_task, :description, :priority, :state, :subject

  belongs_to :author, :class_name => User, :foreign_key => :author_id
  belongs_to :assigned, :class_name => User, :foreign_key => :assigned_id

  belongs_to :workspace

  validates :priority, :inclusion => 0..4
  validates :state, :inclusion => 0..4

  def get_priority
    case self.priority
    when 0
      return "Very low"
    when 1
      return "Low"
    when 2
      return "Medium"
    when 3
      return "High"
    when 4
      return "Very high"
    end
  end

  def get_status
    case self.state
    when 0
      return "Open"
    when 1
      return "Resolved"
    when 2
      return "Feedback"
    when 3
      return "Fixed"
    when 4
      return "Closed"
    end
  end
end
