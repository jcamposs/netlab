require 'cloudstrg/cloudstrg'

class WorkspaceInvitationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_notifications

  # GET /workspace_invitations
  # GET /workspace_invitations.json
  def index
    @user = current_user
    @workspace_invitations = @user.workspace_invitations

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @workspace_invitations }
    end
  end

  # GET /workspace_invitations/1
  # GET /workspace_invitations/1.json
  def show
    @workspace_invitation = WorkspaceInvitation.find(params[:id])
    ws = @workspace_invitation.workspace
    scene = ws.scene
    user = scene.user
    plugin = scene.remote.cloudstrgplugin

    _session = {}
    _params = {:user => user,
               :plugin_id => plugin,
               :redirect => "#{request.protocol}#{request.host_with_port}/scenes",
               :file_id => scene.remote.file_remote_id,
               :share_email => current_user.email,
               :local_file_id => scene.remote.id,
               :user_id => current_user.id,
               :session => _session}

    driver = CloudStrg.new_driver _params
    _session, url = driver.config _params
    
    if not url
      driver.share_file _params

      ws.editors << current_user
      ws.save
      @workspace_invitation.destroy
    
      respond_to do |format|
        format.html { redirect_to ws }
        format.json { render json: @workspace_invitation }
      end
    else
      respond_to do |format|
        format.html { redirect_to home_path }
        format.json { render head: :no_content }
      end
    end
  end

  # GET /workspace_invitations/new
  # GET /workspace_invitations/new.json
  def new
    @workspace_invitation = WorkspaceInvitation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @workspace_invitation }
    end
  end

  # GET /workspace_invitations/1/edit
  def edit
    @workspace_invitation = WorkspaceInvitation.find(params[:id])
  end

  # POST /workspace_invitations
  # POST /workspace_invitations.json
  def create
    @workspace_invitation = WorkspaceInvitation.new(params[:workspace_invitation])

    respond_to do |format|
      if @workspace_invitation.save
        format.html { redirect_to @workspace_invitation, notice: 'Workspace invitation was successfully created.' }
        format.json { render json: @workspace_invitation, status: :created, location: @workspace_invitation }
      else
        format.html { render action: "new" }
        format.json { render json: @workspace_invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /workspace_invitations/1
  # PUT /workspace_invitations/1.json
  def update
    @workspace_invitation = WorkspaceInvitation.find(params[:id])

    respond_to do |format|
      if @workspace_invitation.update_attributes(params[:workspace_invitation])
        format.html { redirect_to @workspace_invitation, notice: 'Workspace invitation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @workspace_invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /workspace_invitations/1
  # DELETE /workspace_invitations/1.json
  def destroy
    @workspace_invitation = WorkspaceInvitation.find(params[:id])
    @workspace_invitation.destroy

    respond_to do |format|
      format.html { redirect_to workspace_invitations_url }
      format.json { head :no_content }
    end
  end
end
