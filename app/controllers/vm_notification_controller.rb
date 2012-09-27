class VmNotificationController < ApplicationController

  #PUT /vm_notification/change_state
  def change_state
    vm = VirtualMachine.find_by_name_and_workspace_id(params["virual_machine"], params["workspace_id"])
    vm.state = params["state"]

    respond_to do |format|
      if vm.save
        format.html { render :nothing => true, status: :ok }
      else
        format.html { render :nothing => true, status: :unprocessable_entity }
      end
    end
  end

end
