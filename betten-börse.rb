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
      slots << { :start => host[:c_host_period_start], :end => host[:c_host_period_end] }
    end
    slots
  end

  def book_slot(slots, guest)
    booking = slots.detect do |slot|
      guest[:c_guest_period_start] >= slot[:start] and guest[:c_guest_period_end] <= slot[:end] and slot[:guest].nil?
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

  end

end
