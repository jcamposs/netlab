class VirtualMachineObserver < ActiveRecord::Observer
  def after_update vm
    if vm.state_changed?
      puts "TODO: Send notification to client side"
      if vm.state_was != "halted" and vm.state == "halted"
        puts "TODO: Kill shellinabox demons for virtual machine #{vm.name}"
      end
    end
  end
end
