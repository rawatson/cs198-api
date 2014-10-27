class Enrollment < ActiveRecord::Base
  belongs_to :course
  belongs_to :person
  belongs_to :position
end
