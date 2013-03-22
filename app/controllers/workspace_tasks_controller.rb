class WorkspaceTasksController < ApplicationController

  before_filter :authenticate_user!
  before_filter :check_notifications

  # GET /workspace_tasks
  # GET /workspace_tasks.json
  def index
    @user = current_user

    respond_to do |format|
      format.html { render "index" }# index.html.erb
      format.json { render json: @user.assigned_workspace_tasks }
    end
  end

  # GET /workspace_tasks/1
  # GET /workspace_tasks/1.json
  def show
    @workspace_task = WorkspaceTask.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @workspace_task }
    end
  end

  # GET /workspace_tasks/new
  # GET /workspace_tasks/new.json
  def new
    @workspace_task = WorkspaceTask.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @workspace_task }
    end
  end

  # GET /workspace_tasks/1/edit
  def edit
    @workspace_task = WorkspaceTask.find(params[:id])
  end

  # POST /workspace_tasks
  # POST /workspace_tasks.json
  def create
    @workspace_task = WorkspaceTask.new(params[:workspace_task])

    respond_to do |format|
      if @workspace_task.save
        format.html { redirect_to @workspace_task.workspace, notice: 'Workspace task was successfully created.' }
        format.json { render json: @workspace_task, status: :created, location: @workspace_task }
      else
        format.html { render @workspace_task.workspace }
        format.json { render json: @workspace_task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /workspace_tasks/1
  # PUT /workspace_tasks/1.json
  def update
    @workspace_task = WorkspaceTask.find(params[:id])

    respond_to do |format|
      if @workspace_task.update_attributes(params[:workspace_task])
        format.html { redirect_to @workspace_task.workspace, notice: 'Workspace task was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to @workspace_task.workspace, notice: 'Error saving task' }
        format.json { render json: @workspace_task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /workspace_tasks/1
  # DELETE /workspace_tasks/1.json
  def destroy
    @workspace_task = WorkspaceTask.find(params[:id])
    @workspace_task.destroy

    respond_to do |format|
      format.html { redirect_to workspace_tasks_url }
      format.json { head :no_content }
    end
  end

  # PUT /workspace_tasks/1/do_auto_task
  # PUT /workspace_tasks/1/do_auto_task.json
  def do_auto_task
    workspace_task = WorkspaceTask.find(params[:id])
    message = "ok"
    code = 200
    if workspace_task.auto_task == "SHARE SCENE"
      ws = workspace_task.workspace
      scene = ws.scene
      user = workspace_task.assigned
      plugin = scene.remote.cloudstrgplugin 
      _params = {:user => user,
                 :plugin_id => plugin,
                 :redirect => "#{request.protocol}#{request.host_with_port}/scenes",
                 :file_id => scene.remote.file_remote_id,
                 :share_email => current_user.email,
                 :local_file_id => scene.remote.id,
                 :user_id => workspace_task.author.id,
                 :session => session}

      driver = CloudStrg.new_driver _params
      _session, url = driver.config _params
      session.merge!(_session)
      if not url
        driver.share_file _params
        workspace_task.status = 5
        workspace_task.save
      else
        message = "Scene not found"
        code = 500
      end
    else
      message = "Unknown task"
      code = 500
    end

    respond_to do |format|
      flash[:notice] = message
      format.html { redirect_to workspace_task.workspace }
      format.json { render json: {:message => message}, status: code }
    end
  end
end
