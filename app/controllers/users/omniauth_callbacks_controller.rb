require 'cloudstrg/cloudstrg'

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)

    if @user.persisted?
    
     _params = {:user => @user, 
             :plugin_id => Cloudstrg::Cloudstrgplugin.find_by_plugin_name("gdrive"), 
             :redirect => "https://localhost:3000/users/auth/google_oauth2/callback", 
             :refresh_token => request.env["omniauth.auth"].credentials["refresh_token"], 
             :access_token => request.env["omniauth.auth"].credentials["access_token"], 
             :expires_in => request.env["omniauth.auth"].credentials["expires_at"], 
             :session => session}
      p _params
      driver = CloudStrg.new_driver _params
      _session, url = driver.config _params
      
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end
