class ShellinaboxObserver < ActiveRecord::Observer
  def before_destroy shellinabox
    #TODO: If the demon is running on this machine then we only have to
    # kill it, if not, we must send a request to the machine where the
    #shellinaboxd is runing to tell it to kill the process.
    if not ShellinaboxSystemTool.stop(shellinabox)
      puts "Warning! Process #{shellinabox.pid} unmanaged"
    end
  end
end
