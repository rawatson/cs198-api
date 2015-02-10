require "test_helper"

describe LairState do
  let(:lair_state) { LairState.new }

  it "must be valid" do
    lair_state.must_be :valid?
    lair_state.signups_enabled.must_equal false
  end
end
