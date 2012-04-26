class HomeController < ApplicationController
  before_filter :authenticate_user!

  def index
    @user = current_user

    #TODO: Calculate the url for shell in a box

    @shell_url = "http://localhost:4200"
    @pid = pid = fork do
      #TODO: Configure the next comand
      exec "shellinaboxd -t"
    end
  end
end
