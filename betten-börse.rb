require 'csv'
require 'date'

class Assignment

  def initialize(host)
    @host = host
  end

  def can_host?(guest)
    !has_guest? and date_compatible?(guest) and gender_compatible(guest) and accessibility_compatible(guest)
  end

  def match_score(guest)
    date_score(guest) + gender_score(guest) + accessibility_score(guest)
  end

  def has_guest?
    !@guest.nil?
  end

  def accessibility_score(guest)
    if (guest[:c_bed_wheelchair] == 1 and @host[:c_bed_wheelchair] == 1)
      1.0
    elsif (guest[:c_bed_wheelchair] != 1 and @host[:c_bed_wheelchair] != 1)
      1.0
    else
      0.0
    end
  end

  def accessibility_compatible(guest)
    guest[:c_bed_wheelchair] != 1 or @host[:c_bed_wheelchair] == 1
  end

  def gender_score(guest)
    if (@host[:c_bed_samegender] == 1 and guest[:c_bed_samegender] == 1)
      1.0
    elsif (@host[:c_bed_samegender] != 1 and guest[:c_bed_samegender] != 1 and @host[:c_bed_gender] != guest[:c_bed_gender])
      1.0
    else
      0.0
    end
  end

  def gender_compatible(guest)
    if guest[:c_bed_samegender] == 1 or @host[:c_bed_samegender] == 1
      guest[:c_bed_gender] == @host[:c_bed_gender]
    else
      true
    end
  end

  def date_score(guest)
    host_start_date = (@host[:c_bed_period_start].nil? ? Date.new(2019, 10, 1) : @host[:c_bed_period_start])
    host_end_date = (@host[:c_bed_period_end].nil? ? Date.new(2019, 10, 20) : @host[:c_bed_period_end])
    host_length = (host_end_date - host_start_date).to_i.to_f
    return 0 if host_length == 0

    guest_start_date = (guest[:c_bed_period_start].nil? ? Date.new(2019, 10, 1) : guest[:c_bed_period_start])
    guest_end_date = (guest[:c_bed_period_end].nil? ? Date.new(2019, 10, 20) : guest[:c_bed_period_end])
    guest_length = (guest_end_date - guest_start_date).to_i.to_f

    return guest_length / host_length
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

  def host_id
    @host[:id]
  end

  def to_s
    return <<-eos
Host: #{Assignment.contact_to_s(@host)} offered #{Assignment.contact_period_to_s(@host)}
\t#{Assignment.matching_options(@host)}
Guest: #{Assignment.contact_to_s(@guest)} requested #{Assignment.contact_period_to_s(@guest)}
\t#{Assignment.matching_options(@guest)}
Booked Period: #{period_to_s}
eos
  end

  class << self

    def matching_options(contact)
      "Gender: #{contact[:c_bed_gender]} Same-gender: #{contact[:c_bed_samegender]} Wheelchair Access: #{contact[:c_bed_wheelchair]}"
    end

    def contact_to_s(contact)
      "#{contact[:firstname]} #{contact[:lastname]} <#{contact[:email]}> (#{contact[:id]})"
    end

    def contact_period_to_s(contact)
      "#{contact[:c_bed_period_start]} to #{contact[:c_bed_period_end]}"
    end

  end

end

class BettenBörse

  CSV::Converters[:yummy_date] = lambda do |field|
    if !field.nil? and field.match(/\d\d\d\d-\d\d-\d\d/)
      Date.parse(field)
    else
      field
    end
  end

  def initialize(options)
    @hosts = BettenBörse.csv_hashes_from_file(options[:hosts])
    @guests = BettenBörse.csv_hashes_from_file(options[:guests])
    @slots_by_host_email = Hash.new
  end

  def create_slots
    slots = []
    @hosts.each do |host|
      if !host[:c_bed_period_start].nil?
        new_slot = Assignment.new(host)
        slots << new_slot
        @slots_by_host_email[host[:email]] = new_slot
      end
    end
    @guests.each do |guest|
      if !guest[:c_bed_host_mail].nil? and @slots_by_host_email.has_key?(guest[:c_bed_host_mail])
        @slots_by_host_email[guest[:c_bed_host_mail]].book_slot_for_guest(guest)
      end
    end
    slots
  end

  def book_slot(slots, guest)
    potential_slots = slots.select { |s| s.can_host?(guest) }
    scores = potential_slots.collect { |s| s.match_score(guest) }
    scored_slots = scores.zip(potential_slots)
    ranked_slots = scored_slots.sort { |a,b| b[0] <=> a[0] }
    if ranked_slots.size > 0
      ranked_slots.first.last.book_slot_for_guest(guest)
    end
  end

  def extract_assignments(slots)
    slots.select { |s| s.has_guest? }
  end

  def print_statistics(slots)
    puts ""
    puts "=-=-=-=- Statistics  -=-=-=-="
    puts "Hosts: #{@hosts.size}"
    puts "Booked slots: #{slots.size}"
    puts "Guests: #{@guests.size}"
    puts "=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
  end

  def run_assignment
    slots = create_slots
    @guests.each do |guest|
      book_slot(slots, guest)
    end
    return extract_assignments(slots)
  end

  def homeless_guests(assignments)
    homeless = []
    homed = Hash.new
    assignments.each do |assignment|
      homed[assignment.guest_id] = true
    end
    @guests.each do |guest|
      if !homed.has_key?(guest[:id])
        homeless << guest
      end
    end
    homeless
  end

  class << self

    def csv_hashes_from_file(file)
      hash = CSV.new(File.read(file), :headers => true, :header_converters => :symbol, :converters => [ :numeric, :yummy_date ])
      hash.to_a.map { |row| row.to_hash }
    end

  end

end

if __FILE__ == $0
  börse = BettenBörse.new(:hosts => ARGV[0], :guests => ARGV[1])
  assignments = börse.run_assignment
  assignments.each do |assignment|
    puts assignment
    puts "---"
  end
  börse.print_statistics(assignments)
  puts ""
  puts "Unhoused visitors:"
  börse.homeless_guests(assignments).each do |guest|
    puts "#{Assignment.contact_to_s(guest)} requested #{Assignment.contact_period_to_s(guest)}"
    puts "\t#{Assignment.matching_options(guest)}"
  end
end
