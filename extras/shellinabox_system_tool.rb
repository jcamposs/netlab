module ShellinaboxSystemTool
  def self.start(vm, user)
    return false if vm.state == "halted"

    r, w = IO.pipe
    proc_id = fork

    if proc_id
      # Reserve a free port by using it, afterwads we will release it
      # at the time of launching the shellinabox demon. That's not an infallible
      # fix due to the port can be reassigned to a different process in the
      # time it is realeased and assigned again.
      svc = TCPServer.new 0
      port = svc.addr[1]

      shell = Shellinabox.new(
        pid: proc_id,
        host_name: Socket.gethostname,
        port_number: port
      )
      shell.virtual_machine = vm
      shell.user = user

      port = -1 if not shell.save

      # Release the port so that it can be used by shellinabox demon
      # Note: This port can be reassigned to a diferent process if a context
      # switch happens altough it's not very likely getting the same port.
      svc.close

      Marshal.dump(port, w)
      Process.detach(proc_id)
      r.close
      w.close
      return port >= 0
    else
      # child
      port = Marshal.load r
      r.close
      w.close

      exit 0 if port < 0 #Shellinabox could not be stored in the data base

      begin
        # service option
        svc = "telnet #{vm.workspace.proxy} #{vm.port_number} -l #{user.id}"
        svc_opt = "/:#{NetlabConf.user}:#{NetlabConf.user}:HOME:#{svc}"

        # css options
        wob = "00_White\ On\ Black.css"
        bow = "00+Black\ on\ White.css"
        css_dir = "#{NetlabConf.shellinabox_dir}/options-enabled/"
        css_opt = "Normal:+#{css_dir}#{wob},Reverse:-#{css_dir}#{bow}"

        exec "shellinaboxd", "--background", "--disable-ssl", "--port=#{port}",
              "--service=#{svc_opt}", "--user-css=#{css_opt}"
      rescue Exception => e
        puts e.message
        shell = Shellinabox.find_by_user_id_and_virtual_machine_id(user.id, vm.id)
        shell.destroy
      ensure
        exit -1
      end
    end
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
end
