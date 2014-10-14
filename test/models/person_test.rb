require 'test_helper'

describe Person do
  let(:person) do
    Person.new(
      suid: '123',
      sunet_id: 'testuser',
      citizen_status: 'US Citizen',
      email: 'testuser@stanford.edu'
    )
  end

  describe 'validation' do
    it 'must validate default person' do
      person.must_be :valid?
    end

    it 'must accept valid citizenship statuses' do
      ['US Citizen', 'Permanent Resident', 'International'].each do |status|
        person.citizen_status = status
        person.must_be :valid?
      end
    end

    it 'must reject invalid citizenship statuses' do
      ['USCitizen', 'Permanent Alien', 'Martian'].each do |status|
        person.citizen_status = status
        person.wont_be :valid?
      end
    end

    it 'must allow nil suids' do
      person.suid = nil
      person.must_be :valid?
    end
  end
end
