class Term < ActiveRecord::Base
  has_many :courses

  @term_types = %w(Autumn Winter Spring Summer)

  validates :year, format: { with: /\A\d{4}-\d{4}\z/ }
  validates :title, inclusion: { in: @term_types }
end
