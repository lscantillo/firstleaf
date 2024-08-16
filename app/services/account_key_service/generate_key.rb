# frozen_string_literal: true

module AccountKeyService
  class GenerateKey

    def initialize(user_id)
      @user = User.find(user_id)
    end

    def call
      HTTParty.post(
        "https://w7nbdj3b3nsy3uycjqd7bmuplq0yejgw.lambda-url.us-east-2.on.aws/v1/account",
        body: { email: @user.email, key: @user.key }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
    end
  end
end