require 'csv'
require 'date'

class Assignment

  def initialize(host)
    @host = host
  end

  def can_host?(guest)
    !has_guest? and date_compatible?(guest)
  end

  def has_guest?
    !@guest.nil?
  end

  def date_compatible?(guest)
   if guest[:c_bed_period_start].nil?
      false
    elsif @host[:c_bed_period_start].nil?
      false
    elsif guest[:c_bed_period_start] >= @host[:c_bed_period_start]
      if guest[:c_bed_period_end].nil? and @host[:c_bed_period_end].nil?
        true
      elsif guest[:c_bed_period_end].nil?
        false
      else
        if @host[:c_bed_period_end].nil? or (guest[:c_bed_period_end] <= @host[:c_bed_period_end])
          true
        else
          false
        end
      end
    else
      false
    end
  end

  def host_period_start
    @host[:c_bed_period_start]
  end

  def host_period_end
    @host[:c_bed_period_end]
  end

  def book_slot_for_guest(guest)
    @guest = guest
  end

  def host_to_s
    "Host: #{Assignment.contact_to_s(@host)}"
  end

  def guest_to_s
    "Guest: #{Assignment.contact_to_s(@guest)}"
  end

  def period_start
    if has_guest?
      @guest[:c_bed_period_start]
    else
      @host[:c_bed_period_start]
    end
  end

  def period_end
    if has_guest?
      @guest[:c_bed_period_end]
    else
      @host[:c_bed_period_end]
    end 
  end

  def period_to_s
    "#{period_start} to #{period_end}"
  end

  def guest_id
    @guest[:id] if has_guest?
  end

  def to_s
    return <<-eos
Host: #{Assignment.contact_to_s(@host)}
Period: #{period_to_s}
Guest: #{Assignment.contact_to_s(@guest)}
eos
  end

  class << self

    def contact_to_s(contact)
      "#{contact[:firstname]} #{contact[:lastname]} <#{contact[:email]}> (#{contact[:id]})"
    end

  end

end

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
      slots << Assignment.new(host) unless host[:c_bed_period_start].nil?
    end
    slots
  end

  def book_slot(slots, guest)
    booking = slots.detect do |slot|
      slot.can_host?(guest)
    end
    booking.book_slot_for_guest(guest) unless booking.nil?
  end

  def extract_assignments(slots)
    slots.select { |s| s.has_guest? }
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

if __FILE__ == $0
  börse = BettenBörse.new(:hosts => ARGV[0], :guests => ARGV[1])
  börse.run_assignment.each do |assignment|
    puts assignment
    puts "---"
  end
end
