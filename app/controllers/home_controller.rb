require 'net/http'

class HomeController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_notifications

  def index
    @user = current_user
    @shell_url = "http://netproxy.libresoft.es"
  end

  def close
    @user = current_user
    payload = '
    {
      "owner" : "userA",
      "group" : "groupA",
      "parameters" : {
        "name" : "pc2"
      }
    }'


    host = 'netlab.libresoft.es'
    port = '10500'
    post_ws = "/virtual_machine/halt"
    json = '{"test" : "tester"}'
    req = Net::HTTP::Post.new(post_ws, initheader = {'Content-Type' =>'application/json'})
    req.body = payload
    @response = Net::HTTP.new(host, port).start {|http| http.request(req) }
  end

end
