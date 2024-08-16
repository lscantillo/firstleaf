require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email: "user@example.com",
      full_name: "John Doe",
      phone_number: "1234567890",
      password: "password123",
      key: SecureRandom.hex(10),
      metadata: "some metadata"
    )
  end

  # Test that a valid user is valid
  test "should be valid" do
    assert @user.valid?
  end

  # Test presence validation for email
  test "email should be present" do
    @user.email = ""
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  # Test uniqueness validation for email
  test "email should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  # Test presence validation for full_name
  test "full_name should be present" do
    @user.full_name = ""
    assert_not @user.valid?
    assert_includes @user.errors[:full_name], "can't be blank"
  end

  # Test presence validation for phone_number
  test "phone_number should be present" do
    @user.phone_number = ""
    assert_not @user.valid?
    assert_includes @user.errors[:phone_number], "can't be blank"
  end

  # Test uniqueness validation for phone_number
  test "phone_number should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:phone_number], "has already been taken"
  end

  # Test length validation for metadata
  test "metadata should be at most 2000 characters" do
    @user.metadata = "a" * 2001
    assert_not @user.valid?
    assert_includes @user.errors[:metadata], "is too long (maximum is 2000 characters)"
  end

  # Test key uniqueness validation
  test "key should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:key], "has already been taken"
  end

  # Test account_key uniqueness validation
  test "account_key should be unique if present" do
    @user.account_key = "unique_account_key"
    @user.save
    duplicate_user = @user.dup
    duplicate_user.account_key = "unique_account_key"
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:account_key], "has already been taken"
  end
end

