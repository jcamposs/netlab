class ShellinaboxSystemTool
  def self.start(vm, user)
    return false if vm.state == "halted"

    user_id = user.id
    vm_port = vm.port_number
    vm_proxy = vm.workspace.proxy

    # Reserve a free port by using it, afterwads we will release it
    # at the time of launching the shellinabox demon. That's not an infallible
    # fix due to the port can be reassigned to a different process in the
    # time it is realeased and assigned again.
    svc = TCPServer.new 0
    port = svc.addr[1]

    # Release the port so that it can be used by shellinabox demon
    # Note: This port can be reassigned to a diferent process if a context
    # switch happens altough it's not very likely getting the same port.
    svc.close

    return false if port < 0

    proc_id = fork do
      begin
        exec_shellinabox(user_id, vm_port, vm_proxy, port)
      rescue Exception => e
        puts e.message
      ensure
        exit -1
      end
    end

    shell = Shellinabox.new(
      pid: proc_id,
      host_name: Socket.gethostname,
      port_number: port
    )
    shell.virtual_machine = vm
    shell.user = user

    if not shell.save
      Process.kill("SIGTERM", proc_id)
      return false
    end

    return true
  end

  def self.stop(shell)
    begin
      puts "Sending signal 'SIGTERM' to shellinaboxd #{shell.pid}"
      Process.kill("SIGTERM", shell.pid)
      return true
    rescue Errno::ESRCH
      # Process is not running
      return true
    rescue Exception => e
      puts e.message
      return false
    end
  end

  def self.exec_shellinabox(user_id, vm_port, vm_proxy, port)
    # service option
    svc = "telnet #{vm_proxy} #{vm_port} -l #{user_id}"
    svc_opt = "/:#{NetlabConf.user}:#{NetlabConf.user}:HOME:#{svc}"

    # css options
    wob = "00_White\ On\ Black.css"
    bow = "00+Black\ on\ White.css"
    color = "01+Color\ Terminal.css"
    monochrome = "01_Monochrome.css"

    enabled_dir = "#{NetlabConf.shellinabox_dir}/options-enabled/"

    css_opt = "Normal:+#{enabled_dir}#{wob},"
    css_opt += "Reverse:-#{enabled_dir}#{bow};"
    css_opt += "Color:+#{enabled_dir}#{color},"
    css_opt += "Monochrome:-#{enabled_dir}#{monochrome}"

    exec "shellinaboxd", "--disable-ssl", "--port=#{port}",
         "--user=#{NetlabConf.user}", "--group=#{NetlabConf.user}",
         "--service=#{svc_opt}", "--user-css=#{css_opt}"
  end
  private_class_method :exec_shellinabox
end
