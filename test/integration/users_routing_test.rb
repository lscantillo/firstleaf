require 'test_helper'

class Api::UsersRoutingTest < ActionDispatch::IntegrationTest
  # Verify that the GET /api/users route maps to the index action
  test "should route GET /api/users to Api::UsersController#index" do
    assert_routing({ method: 'get', path: '/api/users' }, { controller: 'api/users', action: 'index' })
  end

  # Verify that the POST /api/users route maps to the create action
  test "should route POST /api/users to Api::UsersController#create" do
    assert_routing({ method: 'post', path: '/api/users' }, { controller: 'api/users', action: 'create' })
  end
end
