class Subscription < ApplicationRecord
  belongs_to :subscriber
  belongs_to :category
end
