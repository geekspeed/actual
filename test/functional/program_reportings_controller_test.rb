require 'test_helper'

class ProgramReportingsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new_pie_chart" do
    get :new_pie_chart
    assert_response :success
  end

  test "should get new_line_chart" do
    get :new_line_chart
    assert_response :success
  end

end
