class VmNotificationController < ApplicationController

  #PUT /vm_notification/1/change_state
  def change_state
    vm = VirtualMachine.find(params[:id])
    #TODO: Get proper state sent from proxy
    state = "running"
    vm.state = state

    respond_to do |format|
      if vm.save
        format.html { render :nothing => true, status: :ok}
      else
        format.html { render :nothing => true, status: :unprocessable_entity }
      end
    end
  end

end
