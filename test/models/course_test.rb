require 'test_helper'

describe Course do
  let(:course) { Course.new }

  it 'must be valid' do
    course.must_be :valid?
  end
end
