require 'net/http'

class HomeController < ApplicationController
  before_filter :authenticate_user!

  def index
    @user = current_user

    payload = '
    {
      "owner" : "userA",
      "group" : "groupA",
      "parameters" : {
        "name" : "pc2",
        "network" : [
          { "interface" : "eth0", "collision_domain" : "A"},
          { "interface" : "eth1", "collision_domain" : "B"}
        ]
      }
    }'

    host = 'netlab.libresoft.es'
    port = '10500'
    post_ws = "/virtual_machine/start"
    json = '{"test" : "tester"}'
    req = Net::HTTP::Post.new(post_ws, initheader = {'Content-Type' =>'application/json'})
    req.body = payload
    response = Net::HTTP.new(host, port).start {|http| http.request(req) }
    if response.code == '200'
      sleep 5
      resp_object = ActiveSupport::JSON.decode(response.body)
      vm_port = resp_object["port"]
      #TODO: Calculate the url for shell in a box
      @shell_url = "http://netlab.libresoft.es:4200"
      @pid = pid = fork do
        #TODO: Configure the next comand
        exec "shellinaboxd -t -s '/:netlab:netlab:HOME:ssh netlab@localhost \"telnet localhost #{vm_port}\"'"
      end
    end
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
