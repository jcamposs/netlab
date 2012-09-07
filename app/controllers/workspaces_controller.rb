class WorkspacesController < ApplicationController
  before_filter :authenticate_user!

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
    @module = 'Desktop'
    @width = 600
    @height = 500
    @mode = "view"

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @workspace }
    end
  end

  # GET /workspaces/new
  # GET /workspaces/new.json
  def new
    @workspace = Workspace.new
    @module = 'Desktop'
    @width = 600
    @height = 500
    @mode = "view"

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @workspace }
    end
  end

  # GET /workspaces/1/edit
  def edit
    @workspace = Workspace.find(params[:id])
    @module = 'Desktop'
    @width = 600
    @height = 500
    @mode = "view"
  end

  # POST /workspaces
  # POST /workspaces.json
  def create
    @user = current_user
    @scene = Scene.find(params[:workspace][:scene_id])
    @workspace = @scene.workspaces.build(params[:workspace])
    @workspace.user = @user

    @module = 'Desktop'
    @width = 600
    @height = 500
    @mode = "view"

    gen_schema

    respond_to do |format|
      format.html { redirect_to @workspace, notice: 'Workspace was successfully created.' }
      format.json { render json: @workspace, status: :created, location: @workspace }
    end

#    respond_to do |format|
#      if @workspace.save
#        format.html { redirect_to @workspace, notice: 'Workspace was successfully created.' }
#        format.json { render json: @workspace, status: :created, location: @workspace }
#      else
#        format.html { render action: "new" }
#        format.json { render json: @workspace.errors, status: :unprocessable_entity }
#      end
#    end
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

  def create_iface(node, collision_domain)
    vm = VirtualMachine.find_by_name_and_workspace_id(node["name"], @workspace.id)
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

  def gen_schema
    definition = JSON.parse @workspace.scene.definition
    collision_domains = {}
    lan_id = { id: 0}

    Workspace.transaction do
      @workspace.save!

      definition["nodes"].each do |node|

        case node["type"]
        when "hub"
          if collision_domains[node["name"]] == nil
            collision_domains[node["name"]] = create_collision_domain lan_id
            collision_domains[node["name"]].save!
          end
        when "pc", "router", "switch"
          #TODO: Check if this node is in the data base already and throw exception
          virtual_machine = VirtualMachine.new(
            node_type: node["type"],
            name: node["name"])
          virtual_machine.workspace = @workspace
          virtual_machine.save!
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
end
