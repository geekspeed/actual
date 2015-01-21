require 'test_helper'

class DomainMapsControllerTest < ActionController::TestCase
  setup do
    @domain_map = domain_maps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:domain_maps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create domain_map" do
    assert_difference('DomainMap.count') do
      post :create, domain_map: { domain: @domain_map.domain }
    end

    assert_redirected_to domain_map_path(assigns(:domain_map))
  end

  test "should show domain_map" do
    get :show, id: @domain_map
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @domain_map
    assert_response :success
  end

  test "should update domain_map" do
    put :update, id: @domain_map, domain_map: { domain: @domain_map.domain }
    assert_redirected_to domain_map_path(assigns(:domain_map))
  end

  test "should destroy domain_map" do
    assert_difference('DomainMap.count', -1) do
      delete :destroy, id: @domain_map
    end

    assert_redirected_to domain_maps_path
  end
end
