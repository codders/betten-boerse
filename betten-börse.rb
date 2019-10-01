require 'csv'
require 'date'

class BettenBörse

  CSV::Converters[:yummy_date] = lambda do |field|
    if field.match(/\d+\/\d+\/\d\d\d\d/)
      Date.parse(field)
    else
      field
    end
  end

  def initialize(options)
    @hosts = BettenBörse.csv_hashes_from_file(options[:hosts])
    @guests = BettenBörse.csv_hashes_from_file(options[:guests])
  end

  def create_slots
    slots = []
    @hosts.each do |host|
      slots << { :start => host[:c_bed_period_start], :end => host[:c_bed_period_end], :id => host[:id] } unless host[:c_bed_period_start].nil?
    end
    slots
  end

  def book_slot(slots, guest)
    booking = slots.detect do |slot|
      if guest[:c_bed_period_start].nil?
        false
      elsif slot[:start].nil?
        false
      elsif guest[:c_bed_period_start] >= slot[:start]
        if guest[:c_bed_period_end].nil? and slot[:end].nil?
          slot[:guest].nil?
        elsif guest[:c_bed_period_end].nil?
          false
        else
          if slot[:end].nil? or (guest[:c_bed_period_end] <= slot[:end])
            slot[:guest].nil?
          else
            false
          end
        end
      else
        false
      end
    end
    booking[:guest] = guest unless booking.nil?
  end

  def extract_assignments(slots)
    slots.select { |s| !s[:guest].nil? }
  end

  def run_assignment
    slots = create_slots
    @guests.each do |guest|
      book_slot(slots, guest)
    end
    extract_assignments(slots)
  end

  class << self

    def csv_hashes_from_file(file)
      hash = CSV.new(File.read(file), :headers => true, :header_converters => :symbol, :converters => [ :all, :yummy_date ])
      hash.to_a.map { |row| row.to_hash }
    end

    def assignment_to_string(assignment)
      return <<-eos
Host: #{assignment[:id]}
Period: #{assignment[:guest][:c_bed_period_start]} to #{assignment[:guest][:c_bed_period_end]}
Guest: #{assignment[:guest][:id]}
eos
    end

  end

end

if __FILE__ == $0
  börse = BettenBörse.new(:hosts => ARGV[0], :guests => ARGV[1])
  börse.run_assignment.each do |assignment|
    puts BettenBörse.assignment_to_string(assignment)
    puts "---"
  end
end
