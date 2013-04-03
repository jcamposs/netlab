class ApplicationController < ActionController::Base
  protect_from_forgery

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def check_notifications
    @user = current_user
    @workspace_invitations = @user.workspace_invitations
    @num_invitations = @workspace_invitations.length
    @workspace_tasks = @user.assigned_workspace_tasks
    @num_tasks = @workspace_tasks.length
  end

end
