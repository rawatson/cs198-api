module Errors
  module CS198
    class RecordsNotValid < StandardError
      attr_reader :records

      def initialize(message = "Invalid records", invalid_records)
        super(message)
        @records = invalid_records
      end
    end
  end
end
