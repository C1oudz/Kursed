# app/models/verification_code.rb
class VerificationCode < ApplicationRecord
    validates :chat_id, :code, :expires_at, presence: true
  end
  