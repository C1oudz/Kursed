class Subscriber < ApplicationRecord
    has_many :subscriptions, dependent: :destroy
    has_many :subscribed_categories, through: :subscriptions, source: :category
end
