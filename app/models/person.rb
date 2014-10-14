class Person < ActiveRecord::Base
  @citizen_types = ['US Citizen', 'Permanent Resident', 'International']

  validates :suid, uniqueness: true, allow_nil: true
  validates :sunet_id, uniqueness: true
  validates :citizen_status, inclusion: { in: @citizen_types }, allow_nil: true
  validates :email, email: true
end
