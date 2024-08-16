class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true, length: { maximum: 200 }
  validates :full_name, presence: true, length: { maximum: 200 }
  validates :phone_number, presence: true, uniqueness: true, length: { maximum: 20 }
  validates :password, presence: true, length: { maximum: 100 }, if: :password_required?
  validates :key, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :account_key, uniqueness: true, length: { maximum: 100 }, allow_nil: true
  validates :metadata, length: { maximum: 2000 }

  private

  def password_required?
    new_record? || password.present?
  end
end
