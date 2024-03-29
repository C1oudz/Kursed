class CreateVerificationCodes < ActiveRecord::Migration[6.1]
  def change
    create_table :verification_codes do |t|
      t.integer :chat_id
      t.integer :code
      t.datetime :expires_at

      t.timestamps
    end
  end
end
