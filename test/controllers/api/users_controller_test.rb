require 'test_helper'

class Api::UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "user@example.com",
      phone_number: "1234567890",
      full_name: "John Doe",
      password: "password123",
      key: SecureRandom.hex(20),
      metadata: "some metadata"
    )
  end

  # Verify that a request without a query parameter returns all users
  # in the database using the specified JSON format, ordered by most
  # recently created first.
  test "should return all users in descending order" do
    get api_users_url
    assert_response :ok

    response_body = JSON.parse(response.body)
    assert_equal User.count, response_body["users"].size
    assert_equal @user.email, response_body["users"].first["email"]
  end

  # Verify that a request with a query parameter returns users filtered
  # by the query parameter, ordered by most recently created first.
  test "should filter users by email" do
    get api_users_url, params: { email: "user@example.com" }
    assert_response :ok

    response_body = JSON.parse(response.body)
    assert_equal 1, response_body["users"].size
    assert_equal @user.email, response_body["users"].first["email"]
  end

  test "should filter users by full_name" do
    get api_users_url, params: { full_name: "John Doe" }
    assert_response :ok

    response_body = JSON.parse(response.body)
    assert_equal 1, response_body["users"].size
    assert_equal @user.full_name, response_body["users"].first["full_name"]
  end

  # Verify that creating a new user with unique values returns the
  # JSON object and a 201 Created status header.
  test "should create a new user with unique values" do
    assert_difference('User.count', 1) do
      post api_users_url, params: {
        email: "newuser@example.com",
        phone_number: "0987654321",
        full_name: "Jane Doe",
        password: "password123",
        metadata: "female"
      }
    end

    assert_response :created

    response_body = JSON.parse(response.body)
    assert_equal "newuser@example.com", response_body["email"]
    assert_equal "Jane Doe", response_body["full_name"]
    assert_not_nil response_body["key"]
    assert_nil response_body["password_digest"]
  end

  # Verify that creating a new user with non-unique values returns a
  # 422 Unprocessable Entity status and an array of errors.
  test "should not create user with non-unique values" do
    assert_no_difference('User.count') do
      post api_users_url, params: {
        email: "user@example.com", # Email already taken
        phone_number: "1234567890",
        full_name: "Jane Doe",
        password: "password123",
        metadata: "female"
      }
    end

    assert_response :unprocessable_entity

    response_body = JSON.parse(response.body)
    assert_includes response_body["errors"], "Email has already been taken"
    assert_includes response_body["errors"], "Phone number has already been taken"
  end

  # Verify that a new user has a random key generated server-side
  test "should generate a random key for new user" do
    post api_users_url, params: {
      email: "anotheruser@example.com",
      phone_number: "1112223333",
      full_name: "John Smith",
      password: "password123",
      metadata: "male"
    }

    assert_response :created

    user = User.find_by(email: "anotheruser@example.com")
    assert_not_nil user.key
    assert_equal 40, user.key.length
  end

  # Verify that the user's password is stored hashed with a salt value
  test "should store password as hashed value" do
    post api_users_url, params: {
      email: "hasheduser@example.com",
      phone_number: "4445556666",
      full_name: "Hashed User",
      password: "securepassword",
      metadata: "other"
    }

    assert_response :created

    user = User.find_by(email: "hasheduser@example.com")
    assert_not_equal "securepassword", user.password_digest
    assert user.authenticate("securepassword")
  end


end
