class Api::UsersController < ApplicationController
  before_action :validate_query_params, only: [:index]

  # GET /api/users
  def index
    users = filtered_users
    render json: { users: users }, status: :ok
  end

  # POST /api/users
  def create
    user = User.new(user_params)
    user.key = SecureRandom.hex(20)

    if user.save
      AccountKeyJob.perform_async(user.id)
      render json: user.as_json(except: %i[password_digest created_at updated_at]), status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:email, :phone_number, :full_name, :password, :metadata)
  end

  def validate_query_params
    allowed_params = %w[email full_name metadata]
    unless (params.keys - allowed_params - %w[controller action]).empty?
      render json: { error: 'Unprocessable Entity' }, status: :unprocessable_entity
    end
  end

  def filtered_users
    User.order(created_at: :desc).tap do |scope|
      scope.where!("email LIKE ?", "%#{params[:email]}%") if params[:email].present?
      scope.where!("full_name LIKE ?", "%#{params[:full_name]}%") if params[:full_name].present?
      scope.where!("metadata LIKE ?", "%#{params[:metadata]}%") if params[:metadata].present?
    end
  end
end
