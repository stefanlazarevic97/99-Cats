# == Schema Information
#
# Table name: cat_rental_requests
#
#  id         :bigint           not null, primary key
#  cat_id     :bigint           not null
#  start_date :date             not null
#  end_date   :date             not null
#  status     :string           default("PENDING"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class CatRentalRequest < ApplicationRecord
    STATUS_STATES = %w[APPROVED DENIED PENDING].freeze

    validates :status, inclusion: STATUS_STATES
    validates :end_date, :start_date, presence: true
    validate :start_must_come_before_end
    validate :does_not_overlap_approved_request

    belongs_to :cat

    after_initialize :assign_pending_status

    def approve!
        raise 'not pending' unless self.status == 'PENDING'

        transaction do
            self.status = 'APPROVED'
            self.save!

            overlapping_pending_requests.each do |req|
                req.update!(status: 'DENIED')
            end
        end
    end

    def approved?
        self.status == 'APPROVED'
    end

    def denied?
        self.status == 'DENIED'
    end

    def deny!
        self.status = 'DENIED'
        self.save!
    end

    def pending?
        self.status == 'PENDING'
    end

    private

    def assign_pending_status
        self.status ||= 'PENDING'
    end

    def overlapping_requests
        CatRentalRequest
            .where.not(id: self.id)
            .where(cat_id: cat_id)
            .where.not('start_date > :end_date OR end_date < :start_date', start_date: start_date, end_date: end_date)
    end

    def overlapping_approved_requests
        overlapping_requests.where('status = \'APPROVED\'')
    end

    def overlapping_pending_requests
        overlapping_requests.where('status = \'PENDING\'')
    end

    def does_not_overlap_approved_request
        return if self.denied? || overlapping_approved_requests.empty?
        errors.add(:base, 'Request conflicts with existing approved request')
    end

    def start_must_come_before_end
        return if start_date < end_date
        errors.add(:start_date, 'must come before end date')
        errors.add(:end_date, 'must come after start date')
    end
end
