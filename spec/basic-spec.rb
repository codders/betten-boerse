require 'rspec/autorun'
require 'date'
require_relative '../betten-börse'

describe BettenBörse do

  it "should not match guest to host if there is no fit" do
    börse = BettenBörse.new(:hosts => "spec/fixtures/1-hosts.csv", :guests => "spec/fixtures/1-guests.csv")
    assignments = börse.run_assignment
    expect(assignments.size).to eq(0)
  end

  it "should match guest to host if there is a fit" do
    börse = BettenBörse.new(:hosts => "spec/fixtures/2-hosts.csv", :guests => "spec/fixtures/2-guests.csv")
    assignments = börse.run_assignment
    expect(assignments.size).to eq(1)
    expect(assignments.first[:start]).to eq(Date.parse('2019-10-01'))
    expect(assignments.first[:end]).to eq(Date.parse('2019-10-05'))
    expect(assignments.first[:guest][:id]).to eq(1)
  end

  it "should not over-book slots, and book first-come first-served" do
    börse = BettenBörse.new(:hosts => "spec/fixtures/3-hosts.csv", :guests => "spec/fixtures/3-guests.csv")
    assignments = börse.run_assignment
    expect(assignments.size).to eq(1)
    expect(assignments.first[:start]).to eq(Date.parse('2019-10-01'))
    expect(assignments.first[:end]).to eq(Date.parse('2019-10-05'))
    expect(assignments.first[:guest][:id]).to eq(1)
  end

  it "should match host and guest when neither specifies an end period" do
    börse = BettenBörse.new(:hosts => "spec/fixtures/4-no-end-date-hosts.csv", :guests => "spec/fixtures/4-no-end-date-guests.csv")
    assignments = börse.run_assignment
    expect(assignments.size).to eq(1)
    expect(assignments.first[:start]).to eq(Date.parse('2019-10-01'))
    expect(assignments.first[:guest][:id]).to eq(1)
  end

  it "should match guest to host if host specifies no end period" do
    börse = BettenBörse.new(:hosts => "spec/fixtures/5-no-host-end-date-hosts.csv", :guests => "spec/fixtures/5-no-host-end-date-guests.csv")
    assignments = börse.run_assignment
    expect(assignments.size).to eq(1)
    expect(assignments.first[:start]).to eq(Date.parse('2019-10-01'))
    expect(assignments.first[:guest][:id]).to eq(1)
  end


end
