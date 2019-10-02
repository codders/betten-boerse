require 'rspec/autorun'
require 'date'
require_relative '../betten-börse'

describe BettenBörse do

  it "should match by gender where requested, prioritising strict matches" do
    börse = BettenBörse.new(:hosts => "spec/fixtures/6-match-by-gender-hosts.csv", :guests => "spec/fixtures/6-match-by-gender-guests.csv")
    assignments = börse.run_assignment
    expect(assignments.size).to eq(4)
    expect(assignments.collect { |a| [ a.host_id, a.guest_id ]}).to eq([ [ 3, 10 ], [ 4, 9 ], [ 5, 7 ], [ 6, 8 ] ])
  end

=begin
  it "should match by wheelchair accessibility" do
    börse = BettenBörse.new(:hosts => "spec/fixtures/7-match-by-accessibility-hosts.csv", :guests => "spec/fixtures/7-match-by-accessibility-guests.csv")
    assignments = börse.run_assignment
    expect(assignments.size).to eq(1)
    expect(assignments.first.period_start).to eq(Date.parse('2019-10-02'))
    expect(assignments.first.period_end).to eq(Date.parse('2019-10-05'))
    expect(assignments.first.guest_id).to eq(1)
  end
=end
end
