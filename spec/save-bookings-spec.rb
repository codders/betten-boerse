require 'rspec/autorun'
require 'date'
require_relative '../betten-börse'

describe BettenBörse do

  it "should remember previous bookings and not overwrite them" do
    börse = BettenBörse.new(:hosts => "spec/fixtures/7-reload-saved-bookings-hosts.csv", :guests => "spec/fixtures/7-reload-saved-bookings-guests.csv")
    assignments = börse.run_assignment
    expect(assignments.size).to eq(1)
    expect(assignments.first.host_id).to eq(3)
    expect(assignments.first.guest_id).to eq(3)
  end

end
