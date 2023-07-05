# == Schema Information
#
# Table name: cats
#
#  id          :bigint           not null, primary key
#  birth_date  :date             not null
#  color       :string           not null
#  name        :string           not null
#  sex         :string(1)        not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'action_view'

class Cat < ApplicationRecord
    include ActionView::Helpers::DateHelper

    CAT_COLORS = %w[black white orange brown mixed].freeze

    validates :color, inclusion: CAT_COLORS
    validates :sex, inclusion: %w[M F]
    validates :birth_date, :name, presence: true
    validate :birth_date_cannot_be_future

    has_many :rental_requests,
        class_name: :CatRentalRequest,
        dependent: :destroy

    def birth_date_cannot_be_future
        return unless birth_date.present? && birth_date > Date.today
        errors.add(:birth_date, "can't be in the future")
    end

    def age
        time_ago_in_words(birth_date)
    end
end