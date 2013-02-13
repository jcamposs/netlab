module ApplicationHelper

  def flash_class(type)
    case type
    when :notice
      "alert alert-success"
    when :alert
      "alert alert-error"
    when :warning
      "alert alert-error"
    else
      ""
    end
  end

end
