require 'rspec/autorun'
require 'date'
require_relative '../betten-börse'

describe BettenBörse do

  it "should return readable results" do
    börse = BettenBörse.new(:hosts => "spec/fixtures/2-hosts.csv", :guests => "spec/fixtures/2-guests.csv")
    assignments = börse.run_assignment
    expect(assignments.first.to_s).to eq(<<-eos
Host: Max Mustermann <max.mustermann@berlin.de> (3) offered 2019-10-01 to 2019-10-05
	Gender: m Same-gender:  Wheelchair Access: 
Guest: Joe Bloggs <joe.bloggs@london.uk> (1) requested 2019-10-02 to 2019-10-05
	Gender: m Same-gender:  Wheelchair Access: 
Booked Period: 2019-10-02 to 2019-10-05
eos
  )
  end

  it "should return csv-format results suitable for import to cms" do
    börse = BettenBörse.new(:hosts => "spec/fixtures/2-hosts.csv", :guests => "spec/fixtures/2-guests.csv")
    assignments = börse.run_assignment
    csv_output = börse.generate_csv(assignments)
    expect(csv_output).to eq(<<-eos
email,c_bed_host_mail,c_bed_host_firstname,c_bed_host_lastname,c_bed_host_phone,c_bed_host_mm
joe.bloggs@london.uk,max.mustermann@berlin.de,Max,Mustermann,01761234561,@max
eos
  )

  end

end
