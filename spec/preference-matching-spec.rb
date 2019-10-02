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

  it "should match by wheelchair accessibility" do
    börse = BettenBörse.new(:hosts => "spec/fixtures/8-match-by-accessibility-hosts.csv", :guests => "spec/fixtures/8-match-by-accessibility-guests.csv")
    assignments = börse.run_assignment
    expect(assignments.size).to eq(4)
    expect(assignments.collect { |a| [ a.host_id, a.guest_id ]}.sort { |a,b| a[0] <=> b[0] }).to eq([ [ 3, 7 ], [ 4, 9 ], [ 5, 8 ], [ 6, 10 ] ])
  end

  it "should care about how many guest places are requested" do
    börse = BettenBörse.new(:hosts => "spec/fixtures/9-match-by-guest-count-hosts.csv", :guests => "spec/fixtures/9-match-by-guest-count-guests.csv")
    assignments = börse.run_assignment
    expect(assignments.size).to eq(4)
    expect(assignments.collect { |a| [ a.host_id, a.guest_id ]}.sort { |a,b| a[0] <=> b[0] }).to eq([ [ 3, 9 ], [ 4, 10 ], [ 5, 8 ], [ 6, 7 ] ])
  end

end
