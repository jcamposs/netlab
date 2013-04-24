module NetlabAMQP
  def self.create_workspace(workspace, scene, user)
    # Start a communication session with RabbitMQ
    conn = Bunny.new(Rails.configuration.amqp_settings)
    conn.start

    rkey = "workspace.#{ENV["RAILS_ENV"]}.create"

    msg = {
      "workspace" => workspace.id,
      "driver" => "netkit",
      "user" => user.first_name,
      "email" => user.email,
      "web" => "http://netlab.libresoft.es",
      "description" => "Workspace #{workspace.name} based on scene #{scene.name}. Created on #{workspace.created_at}"
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

  def self.destroy_workspace(workspace)
    # Start a communication session with RabbitMQ
    conn = Bunny.new(Rails.configuration.amqp_settings)
    conn.start

    rkey = "workspace.#{ENV["RAILS_ENV"]}.#{workspace.id}.destroy"

    msg = {
      "workspace" => workspace.id
    }

    # open a channel
    ch = conn.create_channel

    # declare default direct exchange which is bound to all queues
    e  = ch.default_exchange

    # publish a message to the exchange which then gets routed to the queue
    e.publish(msg.to_json, {
      :routing_key => rkey,
      :content_type => "application/json"
    })
  end
end
