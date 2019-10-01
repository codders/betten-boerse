require 'rspec/autorun'
require 'date'
require_relative '../betten-börse'

describe BettenBörse do

  it "should return readable results" do
    börse = BettenBörse.new(:hosts => "spec/fixtures/2-hosts.csv", :guests => "spec/fixtures/2-guests.csv")
    assignments = börse.run_assignment
    expect(assignments.first.to_s).to eq(<<-eos
Host: Max Mustermann <max.mustermann@berlin.de> (3)
Period: 2019-10-02 to 2019-10-05
Guest: Joe Bloggs <joe.bloggs@london.uk> (1)
eos
  )
  end

end
