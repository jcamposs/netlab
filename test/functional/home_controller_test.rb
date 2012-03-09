require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get index" do
    sign_in users(:homer)
    get :index
    assert_response :success
  end

end
