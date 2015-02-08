require "test_helper"
require "securerandom"

describe SaveHelper do
  [:array, :hash].each do |type|
    describe :save_multiple do
      (0..4).each do |num_records|
        it "accepts and save #{num_records} valid modifications with #{type} input" do
          people = Person.take num_records
          to_save = people if type == :array
          to_save = Hash[people.map { |p| [p.id, p] }] if type == :hash
          save_multiple to_save # must not raise exception

          people.each do |p|
            p.first_name = SecureRandom.hex
            p.last_name = SecureRandom.hex
          end
          to_save = people if type == :array
          to_save = Hash[people.map { |p| [p.id, p] }] if type == :hash
          save_multiple to_save

          new_people = Person.where(id: people.map(&:id))
          new_people.length.must_equal num_records
          people.each do |p1|
            new_people.each do |p2|
              p1.first_name.must_equal p2.first_name if p1.id == p2.id
              p1.last_name.must_equal p2.last_name if p1.id == p2.id
            end
          end
        end

        (1..num_records).each do |num_errors|
          if num_errors == 1
            desc = "modification"
          else
            desc = "modifications"
          end
          it "must reject #{num_errors} invalid #{desc} with #{num_records} records with "\
            "#{type} input" do
            people = Person.take num_records

            people.take(num_errors).each do |p|
              p.email =  "asdf" # must be a valid email
            end

            to_save = people if type == :array
            to_save = Hash[people.map { |p| [p.id, p] }] if type == :hash
            err = -> { save_multiple to_save }.must_raise Errors::CS198::RecordsNotValid

            err.records.length.must_equal num_errors # correct number of errors

            # extract errors
            if type == :array
              errs = err.records.map { |r| r.errors.full_messages }
            else
              errs = err.records.map do |k, v|
                k.must_equal v.id # keys must match
                v.errors.full_messages
              end
            end
            errs.each { |e| e.must_include "Email is invalid" }
          end
        end
      end
    end
  end
end
