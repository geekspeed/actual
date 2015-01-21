require 'test_helper'

class Admin::Organisations::CustomizeEmailControllerTest < ActionController::TestCase
  test "should get feedback_emails" do
    get :feedback_emails
    assert_response :success
  end

  test "should get comment_emails" do
    get :comment_emails
    assert_response :success
  end

  test "should get admin_invite" do
    get :admin_invite
    assert_response :success
  end

  test "should get team_member_invite" do
    get :team_member_invite
    assert_response :success
  end

  test "should get mentor_offer_invite" do
    get :mentor_offer_invite
    assert_response :success
  end

end
