require 'net/http'
require 'net/https'

class WorkspacesController < ApplicationController
  before_filter :authenticate_user!, :confWidget

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
    @workspaces = Workspace.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @workspaces }
    end
  end

  # GET /workspaces/1
  # GET /workspaces/1.json
  def show
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

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @workspace }
    end
  end

  #PUT /workspaces/1/start
  def start
    respond_to do |format|
      begin
        @workspace = Workspace.find(params[:id])
        #TODO: Send request to the proxy
        cmd = generate_start_cmd params[:virtual_machines]
        send_cmd(cmd, "/virtual_machine/start")

        format.js { render :nothing => true }
      rescue
        format.js { render :nothing => true, status: :unprocessable_entity }
      end
    end
  end

  #PUT /workspaces/1/stop
  def stop
    @workspace = Workspace.find(params[:id])
    #TODO: Send request to the proxy
    cmd = generate_stop_cmd params[:virtual_machines]
  end

  #POST /workspaces/1/configure
  #AJAX to manipulate virtual machine stuff
  def configure
    respond_to do |format|
      format.js
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
  end

  # POST /workspaces
  # POST /workspaces.json
  def create
    @user = current_user
    @scene = Scene.find(params[:workspace][:scene_id])
    @workspace = @scene.workspaces.build(params[:workspace])
    @workspace.user = @user

    # TODO: Set proper proxy
    @workspace.proxy = "193.147.51.218"

    respond_to do |format|
      begin
        gen_schema
        format.html { redirect_to @workspace, notice: 'Workspace was successfully created.' }
        format.json { render json: @workspace, status: :created, location: @workspace }
      rescue
        format.html { render action: "new" }
        format.json { render json: @workspace.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /workspaces/1
  # PUT /workspaces/1.json
  def update
    @workspace = Workspace.find(params[:id])

    respond_to do |format|
      if @workspace.update_attributes(params[:workspace])
        format.html { redirect_to @workspace, notice: 'Workspace was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @workspace.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /workspaces/1
  # DELETE /workspaces/1.json
  def destroy
    @workspace = Workspace.find(params[:id])
    @workspace.destroy

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

  def gen_schema
    definition = JSON.parse @workspace.scene.definition
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
    cmd[:workspace] = @workspace.name
    cmd[:parameters] = []
    cmd
  end

  def generate_start_cmd virtual_machines
    cmd = gen_cmd_header

    virtual_machines.each do |name|
      vm = VirtualMachine.find_by_name_and_workspace_id(name, @workspace.id)
      node = {
        :name => vm.name,
        :type => vm.node_type,
        :network => []
      }

      Interface.find_all_by_virtual_machine_id(vm.id).each do |iface|
        node[:network].push({
          :interface => iface.name,
          :collision_domain => iface.collision_domain.name
        })
      end

      cmd[:parameters].push(node)
    end
    cmd.to_json
  end

  def generate_stop_cmd virtual_machines
    cmd = gen_cmd_header

    virtual_machines.each do |name|
      vm = VirtualMachine.find_by_name_and_workspace_id(name, @workspace.id)
      cmd[:parameters].push({ :name => vm.name })
    end

    cmd.to_json
  end

  def send_cmd(cmd, path)
    uri = URI.parse("https://localhost:4000" + path)
    https = Net::HTTP.new(uri.host,uri.port)
    https.ca_file = "/home/sancane/project/webnetlab/netproxy/keys/final.crt"
    https..verify_mode = OpenSSL::SSL::VERIFY_PEER
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.path)
    req.body = cmd
    res = https.request(req)
    #puts "__________________________Response #{res.code}"
  end
end
