require 'test_helper'

describe Term do
  let(:term) { Term.new year: '2014-2015', title: 'Autumn' }

  describe 'validation' do
    it 'must validate default' do
      term.must_be :valid?
    end

    it 'must accept all seasons' do
      %w(Autumn Winter Spring Summer).each do |title|
        term.title = title
        term.must_be :valid?
      end
    end

    it 'must reject non-seasonal titles' do
      %w(autumn Wanter Sprunge Sumerian).each do |title|
        term.title = title
        term.wont_be :valid?
      end
    end

    it 'must accept year-year format' do
      (2000..2014).each do |year|
        term.year = "#{year}-#{year + 1}"
        term.must_be :valid?
      end
    end

    it 'must reject bad year formats' do
      %w(20211-4 2314_2413 -1243).each do |year|
        term.year = year
        term.wont_be :valid?
      end
    end
  end
end
