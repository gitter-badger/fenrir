require 'test_helper'

class ScrollTestsControllerTest < ActionController::TestCase
  setup do
    @scroll_test = scroll_tests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scroll_tests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scroll_test" do
    assert_difference('ScrollTest.count') do
      post :create, scroll_test: { author: @scroll_test.author, body: @scroll_test.body, title: @scroll_test.title }
    end

    assert_redirected_to scroll_test_path(assigns(:scroll_test))
  end

  test "should show scroll_test" do
    get :show, id: @scroll_test
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scroll_test
    assert_response :success
  end

  test "should update scroll_test" do
    patch :update, id: @scroll_test, scroll_test: { author: @scroll_test.author, body: @scroll_test.body, title: @scroll_test.title }
    assert_redirected_to scroll_test_path(assigns(:scroll_test))
  end

  test "should destroy scroll_test" do
    assert_difference('ScrollTest.count', -1) do
      delete :destroy, id: @scroll_test
    end

    assert_redirected_to scroll_tests_path
  end
end
