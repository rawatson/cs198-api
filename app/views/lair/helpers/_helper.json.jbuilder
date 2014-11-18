json.call helper, :id, :checked_out, :check_out_time
json.person { json.partial! "people/person_limited", person: helper.person }
json.check_in_time helper.created_at
