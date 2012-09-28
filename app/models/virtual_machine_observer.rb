class VirtualMachineObserver < ActiveRecord::Observer
  def after_update vm
    if vm.state_changed?
      puts "TODO: Send notification to client side"
      if vm.state_was != "halted" and vm.state == "halted"
        Shellinabox.destroy_all(["virtual_machine_id = ?", vm.id])
      end
    end
  end
end
