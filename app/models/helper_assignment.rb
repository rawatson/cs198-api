class HelperAssignment < ActiveRecord::Base
  belongs_to :helper_checkin
  belongs_to :help_request
  has_one :helper, through: :helper_checkin, class_name: "Person", source: "person"
  has_one :student, through: :help_request, class_name: "Person", source: "person"
  belongs_to :reassignment, class_name: "HelperAssignment", foreign_key: "reassignment_id"

  # Key: closing reason
  # Value: whether or not request gets closed as well
  @close_status_types = {
    resolved: true,
    reassigned: false,
    left: true
  }

  class << self
    attr_accessor :close_status_types
    def close_status_resolves(close_status)
      return false if close_status.nil?
      close_status = close_status.to_sym
      close_status_types.key?(close_status) && close_status_types[close_status]
    end

    def close_statuses
      @close_status_types.keys.map(&:to_s)
    end
  end

  validates :help_request, presence: true,
                           uniqueness: {
                             conditions: -> { where reassignment: nil },
                             if: -> (a) { a.reassignment.nil? },
                             message: "is already assigned"
                           }
  validates :helper_checkin, presence: true,
                             uniqueness: {
                               conditions: -> { where close_status: nil },
                               if: -> (a) { a.close_status.nil? },
                               message: "is already assigned"
                             }
  validates :close_time, presence: { if: -> (a) { !a.close_status.nil? } }
  validates :close_status, presence: { if: -> (a) { !a.close_time.nil? } }
  validates :close_status, inclusion: { in: close_statuses,
                                        message: "must be one of " +
                                                 close_statuses.to_s },
                           allow_nil: true
  validate :validate_close_time
  validate :validate_request
  validate :validate_helper
  validate :validate_reassignment

  private

  def validate_close_time
    valid_close_time = close_time.nil? || (close_time > claim_time)
    errors.add :close_time, "must occur after claim time" unless valid_close_time
  end

  def validate_helper
    errors.add(:helper_checkin,
               "must not be checked out") if helper_checkin.checked_out && close_status.nil?
  end

  def validate_request
    if close_status.nil?
      errors.add(:help_request, "must be open to assign") unless help_request.open
    elsif self.class.close_status_resolves(close_status)
      errors.add(:help_request, "must be closed to close the assignment " \
                                "without reassigning") if help_request.open
    end
  end

  def validate_reassignment
    if close_status == "reassigned"
      errors.add :close_status, "may not be set to 'reassigned' without " \
      "specifying reassignment id" if reassignment.nil?
    else
      errors.add :reassignment, "must not be set if close_status is not " \
      "set to 'reassigned'" unless reassignment.nil?
    end
  end
end
