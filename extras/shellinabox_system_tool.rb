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
        svc = "telnet #{vm.workspace.proxy} #{vm.port_number} -l #{user.id}"
        exec "shellinaboxd", "--disable-ssl", "--port=#{port}", "--service=/:nugana:nugana:/home/nugana:#{svc}"
      rescue Exception => e
        puts e.message
        shell = Shellinabox.find_by_user_id_and_virtual_machine_id(user.id, vm.id)
        shell.destroy
      ensure
        exit -1
      end
    end
  end
end
