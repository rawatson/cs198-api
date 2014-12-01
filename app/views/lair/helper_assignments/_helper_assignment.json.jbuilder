json.call(assignment, :id, :claim_time, :close_time, :close_status, :student_feedback,
          :helper_feedback, :reassignment_id)
json.help_request do
  json.partial! 'lair/help_requests/help_request',
                request: assignment.help_request,
                current_assignment: false
end
json.helper do
  json.partial! 'lair/helpers/helper',
                helper: assignment.helper_checkin,
                current_assignment: false
end
