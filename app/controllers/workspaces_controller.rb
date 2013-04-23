require 'net/http'
require 'net/https'
require 'sys/proctable'
require 'cloudstrg/cloudstrg'
require 'bunny'
include Sys

class WorkspacesController < ApplicationController
  before_filter :authenticate_user!, :confWidget
  before_filter :capture_cloudstrg_validation, :only => [:index]
  before_filter :check_notifications

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

  #PUT /workspaces/1/stop
  def stop
    respond_to do |format|
      begin
        res = {}
        @workspace = Workspace.find(params[:id])
        running, halted = filter_running_machines params[:virtual_machines]

        if running.length > 0
          cmd = generate_stop_cmd running
          reply = send_cmd(cmd, "/virtual_machine/halt")
          res = JSON.parse(reply)
        end

        halted.each { |name| res[name] = { "status" => "success" } }
        format.json { render json: res.to_json }
      rescue
        format.json { render :nothing => true, status: :unprocessable_entity }
      end
    end
  end

  #POST /workspaces/1/configure
  #AJAX to manipulate virtual machine stuff
  def configure
    @workspace = Workspace.find(params[:id])

    respond_to do |format|
      format.js #configure.js.erb
    end
  end

  #POST /workspaces/1/halt
  #AJAX to manipulate virtual machine stuff
  def halt
    @workspace = Workspace.find(params[:id])

    respond_to do |format|
      format.js #halt.js.erb
    end
  end

  # GET /workspaces/1/manage
  def manage
    @workspace = Workspace.find(params[:id])

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
    @workspace.user = @user

    respond_to do |format|
      begin
        gen_schema get_scene(@scene, @user)
        err, host = amqp_create_msg
        if (not err)
          @workspace.proxy = host
          @workspace.save
          format.html { redirect_to @workspace, notice: 'Workspace was successfully created.' }
          format.json { render json: @workspace, status: :created, location: @workspace }
        else
          #TODO: Destroy workspace
          format.html { render action: "new" }
          format.json { render json: @workspace.errors, status: :unprocessable_entity }
        end
      rescue CloudStrg::ROValidationRequired => e
        #session[:stored_params] = params
        format.html {redirect_to e.message}
      rescue Exception => e
        # TODO: Send amqp destroy resquest
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

  def gen_cmd_header
    cmd = {}
    cmd[:workspace] = @workspace.id
    cmd[:parameters] = []
    cmd
  end

  def generate_stop_cmd virtual_machines
    cmd = gen_cmd_header

    virtual_machines.each do |name|
      vm = VirtualMachine.find_by_name_and_workspace_id(name, @workspace.id)
      cmd[:parameters].push({ :name => vm.name })
    end

    cmd.to_json
  end

  def filter_running_machines virtual_machines
    running = []
    halted = []

    virtual_machines.each do |name|
      vm = VirtualMachine.find_by_name_and_workspace_id(name, @workspace.id)
      if vm.state != "halted"
        running.push name
      else
        halted.push name
      end
    end

    return [running, halted]
  end

  def send_cmd(cmd, path)
    uri = URI.parse("https://localhost:4000#{path}.json")
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true
    #TODO: Set a proper certification directory
    https.ca_file = "/home/nugana/Projects/weblab/netproxy/keys/final.crt"
    https.verify_mode = OpenSSL::SSL::VERIFY_PEER

    req = Net::HTTP::Post.new(uri.path)
    req.content_type = 'application/json'
    req.body = cmd
    res = https.request(req)

    raise unless res.kind_of? Net::HTTPSuccess

    res.body
  end

  def get_shellinabox_conf_obj vm
    shell = Shellinabox.find_by_user_id_and_virtual_machine_id(current_user.id, vm.id)
    if shell
      return {
        "status" => "success",
        "host" => shell.host_name,
        "port" => shell.port_number
      }
    else
      return {
        "status" => "error",
        "cause" => "Can not connect remote console"
      }
    end
  end

  private
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

  def amqp_create_msg
    # Start a communication session with RabbitMQ
    conn = Bunny.new(Rails.configuration.amqp_settings)
    conn.start

    rkey = "workspace.#{ENV["RAILS_ENV"]}.create"

    msg = {
      "workspace" => @workspace.id,
      "driver" => "netkit",
      "user" => @user.first_name,
      "email" => @user.email,
      "web" => "http://netlab.libresoft.es",
      "description" => "Workspace #{@workspace.name} based on scene #{@scene.name}. Created on #{@workspace.created_at}"
    }

    # open a channel
    ch = conn.create_channel

    # Create a queue to get the machine host
    q  = ch.queue("", :auto_delete => true)

    # declare default direct exchange which is bound to all queues
    e  = ch.default_exchange

    # publish a message to the exchange which then gets routed to the queue
    e.publish(msg.to_json, {
      :routing_key => rkey,
      :content_type => "application/json",
      :reply_to => q.name
    })

    err = nil
    host = nil

    # fetch a message from the queue
    q.subscribe(:ack => true, :timeout => 10, :message_max => 1,
                        :block => true) do |delivery_info, properties, payload|
      begin
        rsp = JSON.parse(payload)
        if (rsp["status"] == "error")
          err = rsp["cause"]
        else
          host = rsp["host"]
        end
      rescue Exception => e
        puts e.message
        puts e.backtrace
        err = "Unexpected error"
      ensure
        # close the connection
        conn.stop
      end
    end

    return err, host
  end
end
