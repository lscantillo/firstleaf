class AccountKeyJob
  include Sidekiq::Job

  queue_as :default
  sidekiq_options retry: 5, backtrace: true

  def perform(user_id)
    user = User.find(user_id)
    response = fetch_account_key(user)

    if response.success?
      update_account_key(user, response)
    else
      raise "Failed to fetch account key"
    end
  end

  private

  def fetch_account_key(user)
    AccountKeyService::GenerateKey.new(user.id).call
  end

  def update_account_key(user, response)
    account_key = JSON.parse(response.body)["account_key"]
    user.update(account_key: account_key) if account_key.present?
  end
end
