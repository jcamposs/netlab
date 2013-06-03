require 'cloudstrg/cloudstrg'
require 'net/http'
require 'bunny'

class WorkspacesController < ApplicationController
  before_filter :authenticate_user!, :except => [:conf]
  before_filter :confWidget, :except => [:conf]
  before_filter :capture_cloudstrg_validation, :only => [:index]
  before_filter :check_notifications, :except => [:conf]

  def confWidget
    #TODO: Choose the widget that fits better in user's device screen
    @module = 'Desktop'
    @width = 600
    @height = 500
    @mode = "view"
  end

  # GET /workspaces
  # GET /workspaces.json
  def index
    @user = current_user
    @workspaces = @user.workspaces
    @workspaces += @user.editorworkspaces
    @workspace = @workspaces[0] # Default workspace

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @workspaces }
    end
  end

  # GET /workspaces/1
  # GET /workspaces/1.json
  def show
    @user = current_user
    @workspace = Workspace.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @workspace }
    end
  end

  # GET /workspaces/new
  # GET /workspaces/new.json
  def new
    @workspace = Workspace.new
    @user = current_user

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @workspace }
    end
  end

  # GET /workspaces/1/manage
  def manage
    @workspace = Workspace.find(params[:id])
    @mode = "management"
    @handler = "WStreaming"

    respond_to do |format|
      format.html # manage.html.erb
      format.json { render json: @workspace }
    end
  end

  # GET /workspaces/1/edit
  def edit
    @workspace = Workspace.find(params[:id])
    
    respond_to do |format|
      @user = current_user
      if @user == @workspace.user
        format.html # manage.html.erb
        format.json { render json: @workspace }
      else
        flash[:notice] = "Forbidden action"
        format.html { redirect_to workspaces_path }
        format.json { render json: {:error => "Forbidden action"} }
      end
    end
    
  end

  # POST /workspaces
  # POST /workspaces.json
  def create
    @user = current_user
    @scene = Scene.find(params[:workspace][:scene_id])
    @workspace = @scene.workspaces.build(params[:workspace])
    @workspace.session = session
    @workspace.user = @user
    respond_to do |format|
      begin
        gen_schema get_scene(@scene, @user)
        err, host = NetlabAMQP.create_workspace(@workspace, @scene, @user)
        if (not err)
          @workspace.proxy = host
          @workspace.config_file = nil
          @workspace.save
          format.html { redirect_to @workspace, notice: 'Workspace was successfully created.' }
          format.json { render json: @workspace, status: :created, location: @workspace }
        else
          @workspace.destroy
          flash[:notice] = "Workspace could not be created"
          format.html { redirect_to workspaces_path }
          format.json { render json: {:error => "Can not create workspace"}}
        end
      rescue CloudStrg::ROValidationRequired => e
        #session[:stored_params] = params
        format.html {redirect_to e.message}
      rescue Exception => e
        puts e.message
        puts e.backtrace
        format.html { render action: "new" }
        format.json { render json: @workspace.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /workspaces/1
  # PUT /workspaces/1.json
  def update
    @user = current_user
    @workspace = Workspace.find(params[:id])
    @workspace.session = session

    respond_to do |format|
      if current_user == @workspace.user
        if @workspace.update_attributes(params[:workspace])
          format.html { redirect_to @workspace, notice: 'Workspace was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @workspace.errors, status: :unprocessable_entity }
        end
      else
        flash[:notice] = "You are not allowed to do this action"
        format.html { render action: "edit" }
        format.json { render json: {:error => "not allowed"} }
      end
    end
  end

  # DELETE /workspaces/1
  # DELETE /workspaces/1.json
  def destroy
    @workspace = Workspace.find(params[:id])
    @user = current_user
    
    if @user == @workspace.user
      NetlabAMQP.destroy_workspace(@workspace)
      @workspace.destroy
    else
      @workspace.editors.delete(@user)
      @workspace.save
      scene = @workspace.scene
      user = scene.user
      plugin = scene.remote.cloudstrgplugin

      _session = {}
      _params = {:user => user,
               :plugin_id => plugin,
               :redirect => "#{request.protocol}#{request.host_with_port}/workspaces",
               :file_id => scene.remote.file_remote_id,
               :local_file_id => scene.remote.id,
               :user_id => @user.id,
               :session => _session}

      driver = CloudStrg.new_driver _params
      _session, url = driver.config _params
      if not url
        driver.unshare_file _params
      end
    end

    respond_to do |format|
      format.html { redirect_to workspaces_url }
      format.json { head :no_content }
    end
  end

  # GET /workspaces/1/conf
  # GET /workspaces/1/conf.json
  def conf
    workspace = Workspace.find(params[:id])
    if workspace.scene_config
      if request.format == "html"
        # Generate filename
        uri = URI(workspace.scene_config.url)
        filename = workspace.scene_config.name
        directory = Rails.root.join('public', 'uploads')
        filepath = File.join(directory,"#{rand(1000000000)}")

        # Download file
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        req = Net::HTTP::Get.new(uri.request_uri)
        resp = http.request(req)

	if resp.code == "302"
          uri = URI(resp["location"])
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE

          req = Net::HTTP::Get.new(uri.request_uri)
          resp = http.request(req)
          
        end

        File.open(filepath, "wb") { |f| f.write(resp.body)}
      end
      respond_to do |format|
        format.html { send_file filepath, :filename => filename, :type => 'application/x-gzip' }
        format.json { render json: workspace.scene_config.to_json(:only => [:url]) }
      end
      if request.format == "html"
        File.delete(filepath)
      end
    else
      respond_to do |format|
        format.html { redirect_to workspace }
        format.json { head :no_content }
      end
    end
  end



  private
  def create_iface(node, collision_domain)
    vm = VirtualMachine.find_by_name_and_workspace_id(node["name"], @workspace.id)
    if vm == nil
      @workspace.errors.add(:base, "Corrupted stage: Connection with an undefined node \"#{node["name"]}\"")
      raise
    end

    iface = Interface.new(
      name: node["iface"])
    iface.virtual_machine = vm
    iface.collision_domain = collision_domain
    iface
  end

  def create_collision_domain lan_id
    collision_domain = CollisionDomain.new
    collision_domain.workspace = @workspace
    collision_domain.name = "wk#{@workspace.id}cd#{lan_id[:id]}"
    lan_id[:id] = lan_id[:id] + 1
    collision_domain
  end

  def raise_error_if_exists(node, collision_domains)
    if node["type"] == "hub"
      vm = collision_domains[node["name"]]
    else
      vm = VirtualMachine.find_by_name_and_workspace_id(node["name"], @workspace.id)
    end

    return if (vm == nil)

    @workspace.errors.add(:base, "Corrupted stage: Node \"#{node["name"]}\" is not unique")
    raise
  end
  
  def get_scene(user, scene)
    _plugin = @scene.remote.cloudstrgplugin
    _params = {:user => @user, :plugin_id => _plugin, :redirect => "#{request.protocol}#{request.host_with_port}/workspaces", :session => session}
    driver = CloudStrg.new_driver _params
    _session, url = driver.config _params
    session.merge!(_session)
    raise CloudStrg::ROValidationRequired, url if url
    
    _params = {:fileid => @scene.remote.file_remote_id}

    _, _, content = driver.get_file _params
    return JSON.parse content
  end

  def gen_schema definition
    collision_domains = {}
    lan_id = { id: 0}

    Workspace.transaction do
      @workspace.save!

      definition["nodes"].each do |node|
        raise_error_if_exists(node, collision_domains)

        case node["type"]
        when "hub"
          collision_domains[node["name"]] = create_collision_domain lan_id
          collision_domains[node["name"]].save!
        when "pc", "router", "switch"
          virtual_machine = VirtualMachine.new(
            node_type: node["type"],
            name: node["name"])
          virtual_machine.workspace = @workspace
          virtual_machine.save!
        else
          @workspace.errors.add(:base, "Corrupted stage: Node \"#{node["name"]}\" has an unprocessable type \"#{node["type"]}\"")
          raise
        end
      end

      definition["connections"].each do |conn|
        if collision_domains[conn["node1"]["name"]] != nil
          iface = create_iface(conn["node2"], collision_domains[conn["node1"]["name"]])
          iface.save!
        elsif collision_domains[conn["node2"]["name"]] != nil
          iface = create_iface(conn["node1"], collision_domains[conn["node2"]["name"]])
          iface.save!
        else
          collision_domain = create_collision_domain lan_id
          collision_domain.save!

          iface1 = create_iface(conn["node1"], collision_domain)
          iface1.save!
          iface2 = create_iface(conn["node2"], collision_domain)
          iface2.save!
        end
      end
    end
  end

  def capture_cloudstrg_validation
    @user = current_user
    if session.has_key? :plugin_name
      plugin = Cloudstrg::Cloudstrgplugin.find_by_plugin_name(session[:plugin_name])
      session.delete(:plugin_name)

      _params = params
      _params.merge!({:plugin_id => plugin, :user => @user, :redirect => "#{request.protocol}#{request.host_with_port}/workspaces", :session => session})
      driver = CloudStrg.new_driver _params
      _session, url = driver.config _params
      session.merge!(_session)
    end
  end
end
