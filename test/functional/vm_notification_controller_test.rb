require 'test_helper'

class VmNotificationControllerTest < ActionController::TestCase
  test "should get change_state" do
    get :change_state
    assert_response :success
  end

end
