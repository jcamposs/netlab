class ChatInvitationsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :check_notifications
  
  # GET /chat_invitations/1
  # GET /chat_invitations/1.json
  def show
    @chat_invitation = ChatInvitation.find(params[:id])
    url = @chat_invitation.url
    @chat_invitation.destroy
    redirect_to(url.to_s)
  end

  # POST /chat_invitations
  # POST /chat_invitations.json
  def create
    @users_id = params[:receivers_ids]
    @workspace = Workspace.find_by_id(params[:chat_invitation][:workspace_id])
    
    begin
      @users_id.each do |id|
        @user = User.find_by_id(id)
        @chat_invitation = ChatInvitation.new
        @chat_invitation.sender_id = params[:chat_invitation][:sender_id]
        @chat_invitation.receiver_id = id
        @chat_invitation.url = params[:chat_invitation][:url]
        @user.receiver_chat_invitations << @chat_invitation
      end
    
      respond_to do |format|
        format.html { redirect_to manage_workspace_path(@workspace), notice: 'Chat invitation was successfully sended.' }
        format.json { render json: manage_workspace_path(@workspace), status: :created, location: manage_workspace_path(@workspace) }
      end
    rescue
      respond_to do |format|
        format.html { render action: "new" }
        format.json { render json: manage_workspace_path(@workspace).errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /chat_invitations/1
  # DELETE /chat_invitations/1.json
  def destroy
    @chat_invitation = ChatInvitation.find(params[:id])
    @chat_invitation.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end
end