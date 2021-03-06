
require 'cloudstrg/cloudstrg'

INCLUDED_METHODS = [:show, :edit, :update, :delete, :destroy, :back_edit_ajax, :show_edit_ajax]

class ScenesController < ApplicationController
  before_filter :authenticate_user!, :confWidget, :capture_cloudstrg_validation
  before_filter :set_cloudstrg_params, :only => INCLUDED_METHODS
  before_filter :check_notifications

  def confWidget
    #TODO: Choose the widget that fits better in user's device screen
    @module = 'Desktop'
    @width = 600
    @height = 500
  end

  # GET /scenes
  # GET /scenes.json
  def index
    @user = current_user
    @scenes = []
    #if @user.cloudstrgconfig
      #@scenes = @user.scenes.joins(:remote).where(:cloudstrg_remoteobjects => {:cloudstrgplugin_id => @user.cloudstrgconfig.cloudstrgplugin})
    #end
    @scenes = @user.scenes
    @scene = @scenes[0] # Default scene
    @mode = "view"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @scenes }
    end
  end

  # GET /scenes/1
  # GET /scenes/1.json
  def show 
    _params = {:fileid => @scene.remote.file_remote_id}

    _, _, content = @driver.get_file _params
    @scene.definition = content
    @mode = "view"

    # Error in case of an AJAX delete error response
    @err_type = "Error delete"
    @err_msg = "You are not allowed to destroy this scene. Only the owner can delete it."

    respond_to do |format|
      format.html { render :show }# show.html.erb
      format.js
      format.json { render json: { :id => @scene.id, 
                                   :name => @scene.name, 
                                   :user_id => @scene.user_id, 
                                   :definition => @scene.definition
                                 } 
                  }
    end
  end

  # GET /scenes/new
  # GET /scenes/new.json
  def new
    @scene = Scene.new
    @mode = "edit"

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @scene }
    end
  end

  # GET /scenes/1/edit
  def edit
    respond_to do |format|
      
      if @user == @scene.user
        _params = {:fileid => @scene.remote.file_remote_id}

        _, _, content = @driver.get_file _params  
        @scene.definition = content
        @mode = "edit"

        format.html { render :edit }
      else
        flash[:notice] = "You are not allowed to edit this scene"
        format.html { redirect_to scenes_path }
      end
    end
   
  end

  # POST /scenes
  # POST /scenes.json
  def create
    @user = current_user
    @scene = @user.scenes.build(params[:scene])
    @scene.redirection_url = "#{request.protocol}#{Netlab::Application.config.app_host_and_port}/scenes"
    @scene.session = session
    @mode = "edit"

    respond_to do |format|
      begin
        if @scene.save
          session.merge!(@scene.session)
          format.html { redirect_to @scene, notice: 'Scene was successfully created.' }
          format.json { render json: @scene, status: :created, location: @scene }
        else
          format.html { render action: "new", notice: 'Creation failed' }
          format.json { render json: @scene.errors, status: :unprocessable_entity }
        end
      rescue CloudStrg::RONotConfigured => e
        s = Netlabsession.find_by_user_id_and_session_id(@user, session[:session_id])
        if not s
          s = Netlabsession.new :user_id => @user, :session_id => session[:session_id]
        end
        s.h_params = params
        s.save
        format.html { redirect_to cloudstrg.configs_path(:redirection_url => "#{request.protocol}#{Netlab::Application.config.app_host_and_port}/scenes", :notice => 'Please, create a plugin configuration before continue.')  }
        #format.json { redirect_to cloudstrg.configs_path }
        #format.js { redirect_to cloudstrg.configs_path }
      rescue CloudStrg::ROValidationRequired => e
        session.merge!(@scene.session)
        s = Netlabsession.find_by_user_id_and_session_id(@user, session[:session_id])
        if not s
          s = Netlabsession.new :user_id => @user, :session_id => session[:session_id]
        end
        s.h_params = params
        s.save
        format.html {redirect_to e.message}
        #format.json { redirect_to e.message }
        #format.js {render :js => "window.location.href='#{e.message}'"}
      rescue Exception => e
        puts e.message
        puts e.backtrace
        format.html { render action: "new", notice: 'Creation failed' }
        format.json { render json: @scene.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /scenes/1
  # PUT /scenes/1.json
  def update
    @mode = "edit"
    
    respond_to do |format|
      if @scene.update_attributes(params[:scene])
        format.html { redirect_to @scene, notice: 'Scene was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @scene.errors, status: :unprocessable_entity }
      end
    end
  end

  # Used to manage AJAX delete requests with JQuery dialog
  def delete
    @err_type = "Error delete"

    if @scene.user == @user
      @err_msg = "Unexpected error happened."
      respond_to do |format|
        format.html { redirect_to scenes_path }
        format.js # delete.js.erb
      end
    else
      @err_msg = "You are not allowed to destroy this scene. Only the owner can delete it."
      respond_to do |format|
        format.html { redirect_to scenes_path }
        format.js { render partial: "error_msg" }
      end
    end
  end

  def back_new_ajax
    @warn_msg = "This scene has not been saved. Do you really want to leave?"
    @go_path = scenes_path

    respond_to do |format|
      format.js
    end
  end

  def back_edit_ajax
    @warn_msg = "This scene has been modified. Changes done will be lost If you leave without saving. Do you really want to continue?"
    @go_path = scenes_path

    respond_to do |format|
      format.js { render :partial => "check_scene_changes" }
    end
  end

  def show_edit_ajax
    @warn_msg = "This scene has been modified. Changes done will be lost If you leave without saving. Do you really want to continue?"
    @go_path = scene_url(@scene)

    respond_to do |format|
      format.js { render :partial => "check_scene_changes" }
    end
  end

  # DELETE /scenes/1
  # DELETE /scenes/1.json
  def destroy
    if @scene.user == @user
      @scene.destroy
      session.merge!(@scene.session)
      respond_to do |format|
        format.html { redirect_to scenes_url }
        format.js { render :nothing => true }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to scenes_url, notice: 'Not allowed.' }
        format.js { render :nothing => true, status: :unprocessable_entity }
        format.json { head :no_content }
      end
    end
  end

  private
  def capture_cloudstrg_validation
    @user = current_user
    s = Netlabsession.find_by_user_id_and_session_id(@user, session[:session_id])
    puts "Refererrrr:   #{request.referer}"
    continue_stored = false
    if request.referer == "#{request.protocol}#{Netlab::Application.config.app_host_and_port}/cloudstrg/configs"
      continue_stored = true
    end
    if session.has_key? :plugin_name
      plugin = Cloudstrg::Cloudstrgplugin.find_by_plugin_name(session[:plugin_name])
      session.delete(:plugin_name)

      _params = params
      _params.merge!({:plugin_id => plugin, :user => @user, :redirect => "#{request.protocol}#{Netlab::Application.config.app_host_and_port}/scenes", :session => session})
      driver = CloudStrg.new_driver _params
      if driver.check_referer request.referer
        continue_stored = true
        _session, url = driver.config _params
        session.merge!(_session)
        if url
          if not s
            s = Netlabsession.new :user_id => @user, :session_id => session[:session_id]
          end
          s.h_params = params
          s.save
          respond_to do |format|
            format.html {redirect_to url}
            format.json { render :json => { :redirect => url } }
            format.js {render :js => "window.location.href='#{url}'"}
          end
          return
        end
      end
    end
    if s
      if continue_stored
        if not params.has_key? :error
          params.deep_merge!(JSON.parse(s.params))
        end
        s.destroy
        if INCLUDED_METHODS.include? params[:action].to_sym
          set_cloudstrg_params
        end
        send(params[:action])
      else
        s.destroy
      end
    end
  end

  def set_cloudstrg_params
    @scene = Scene.find(params[:id])
    @user = current_user
    if not @scene.remote
      if not @user.cloudstrgconfig
        respond_to do |format|
          format.html { redirect_to cloudstrg.configs_path }
          format.json { redirect_to cloudstrg.configs_path }
          format.js { redirect_to cloudstrg.configs_path }
        end
      else
        plugin = @user.cloudstrgconfig.cloudstrgplugin
      end 
    else
      plugin = @scene.remote.cloudstrgplugin
    end
    
    if params[:redirect_url]
      _params = {:user => @user, :plugin_id => plugin, :redirect => params[:redirect_url], :session => session}
    else
      _params = {:user => @user, :plugin_id => plugin, :redirect => "#{request.protocol}#{Netlab::Application.config.app_host_and_port}/scenes", :session => session}
    end

    if not @driver
      @driver = CloudStrg.new_driver _params
      _session, url = @driver.config _params
      session.merge!(_session)

      @scene.redirection_url = "#{request.protocol}#{Netlab::Application.config.app_host_and_port}/scenes"
      @scene.session = session
      if url
        s = Netlabsession.find_by_user_id_and_session_id(@user, session[:session_id])
        if not s
          s = Netlabsession.new :user_id => @user, :session_id => session[:session_id]
        end
        s.h_params = params
        s.save
        respond_to do |format|
          format.html {redirect_to url}
          format.json { render :json => { :redirect => url } }
          format.js {render :js => "window.location.href='#{url}'"}
        end
      end
    end 
  end
end
