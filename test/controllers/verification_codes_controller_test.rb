require "test_helper"

class VerificationCodesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get verification_codes_new_url
    assert_response :success
  end

  test "should get create" do
    get verification_codes_create_url
    assert_response :success
  end
end
