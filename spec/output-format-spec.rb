require 'rspec/autorun'
require 'date'
require_relative '../betten-börse'

describe BettenBörse do

  it "should return readable results" do
    börse = BettenBörse.new(:hosts => "spec/fixtures/2-hosts.csv", :guests => "spec/fixtures/2-guests.csv")
    assignments = börse.run_assignment
    expect(BettenBörse.assignment_to_string(assignments.first)).to eq(<<-eos
Host: 3
Period: 2019-10-02 to 2019-10-05
Guest: 1
eos
  )
  end

end
