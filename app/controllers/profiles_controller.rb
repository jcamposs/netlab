class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_notifications

  # GET /profiles/1
  # GET /profiles/1.json
  def show 
    @user = User.find(params[:id])
    respond_to do |format|
      if current_user == @user
        format.html # show.html.erb
        #format.js
        format.json { render json: @user }
      else
        format.html # show.html.erb
        #format.js
        format.json { render json: @user.to_json(:only => [:created_at, :id, :first_name, :last_name]) }
      end
    end
  end

  # GET /profiles/1/edit
  def edit
    @user = User.find(params[:id])
    
    respond_to do |format|
      if @user == current_user
        format.html # edit.html.erb
        format.json { render json: @user }
      else
        flash[:notice] = "Forbidden action"
        format.html { redirect_to @user }
        format.json { render json: {:error => "Forbidden action"} }
      end
    end
  end

  # PUT /profiles/1
  # PUT /profiles/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if current_user == @user
        if @user.update_attributes(params[:user])
          format.html { redirect_to "/profiles/#{@user.id}", notice: 'User was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      else
        flash[:notice] = "You are not allowed to do this action"
        format.html { render action: "edit" }
        format.json { render json: {:error => "not allowed"} }
      end
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.json
  def destroy
    @user = User.find(params[:id])

    respond_to do |format|
      if current_user == @user
        @user.destroy

        format.html { redirect_to root_path }
        format.json { head :no_content }
      else
        flash[:notice] = "You are not allowed to do this action"
        format.html { render action: "show" }
        format.json { render json: {:error => "not allowed"} }
      end
    end
  end
end
