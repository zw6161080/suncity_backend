require "test_helper"

describe EntryList do
  let(:entry_list) { EntryList.new }

  it "must be valid" do
    value(entry_list).must_be :valid?
  end
end
