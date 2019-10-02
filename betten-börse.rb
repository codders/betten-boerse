require 'csv'
require 'date'

class Assignment

  def initialize(host)
    @host = host
  end

  def host
    @host
  end

  def guest_email
    return @guest[:email] if @guest
  end

  def can_host?(guest)
    !has_guest? and date_compatible?(guest) and capacity_compatible?(guest) and gender_compatible(guest) and accessibility_compatible(guest)
  end

  def match_score(guest)
    date_score(guest) + capacity_score(guest) + gender_score(guest) + accessibility_score(guest)
  end

  def has_guest?
    !@guest.nil?
  end

  def capacity_score(guest)
    hosting_capacity = Assignment.contact_capacity(@host)
    guest_capacity = Assignment.contact_capacity(guest)
    return guest_capacity.to_f / hosting_capacity.to_f
  end

  def capacity_compatible?(guest)
    hosting_capacity = Assignment.contact_capacity(@host)
    guest_capacity = Assignment.contact_capacity(guest)
    hosting_capacity >= guest_capacity
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
\t#{Assignment.matching_options_to_s(@host)}
Guest: #{Assignment.contact_to_s(@guest)} requested #{Assignment.contact_period_to_s(@guest)}
\t#{Assignment.matching_options_to_s(@guest)}
Booked Period: #{period_to_s}
eos
  end

  class << self

    def contact_capacity(contact)
      places = contact[:c_bed_places]
      if places.nil?
        return 1
      elsif places.class != Integer
        return 1
      elsif places < 1
        return 1
      else
        return places
      end
    end

    def matching_options_to_s(contact)
      "Gender: #{contact[:c_bed_gender]} Same-gender: #{contact[:c_bed_samegender]} Wheelchair Access: #{contact[:c_bed_wheelchair]} Places: #{contact[:c_bed_places]} Comment: #{contact[:c_bed_comment]}"
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

  CSV::Converters[:boolean_to_int] = lambda do |field|
    if !field.nil? and field.match(/^[01]$/)
      field == "1" ? 1 : 0
    else
      field
    end
  end

  CSV::Converters[:natural_numbers] = lambda do |field|
    if !field.nil? and field.match(/^[1-9][0-9]*$/)
      field.to_i
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

  def generate_csv(assignments)
    CSV.generate do |csv|
      csv << [ "email", "c_bed_host_mail", "c_bed_host_firstname", "c_bed_host_lastname", "c_bed_host_phone", "c_bed_host_mm" ]
      assignments.each do |assignment|
        host = assignment.host
        csv << [ assignment.guest_email, host[:email], host[:firstname], host[:lastname], host[:mobile], host[:c_mattermost_handle] ]
      end
    end
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
      hash = CSV.new(File.read(file), :headers => true, :header_converters => :symbol, :converters => [ :boolean_to_int, :natural_numbers, :yummy_date ])
      hash.to_a.map { |row| row.to_hash }
    end

  end

end

if __FILE__ == $0
  require 'optparse'

  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: betten_börse.rb [options]"

    opts.on("-h", "--hosts FILE", "Hosts CSV file") do |h|
      options[:hosts] = h
    end

    opts.on("-g", "--guests FILE", "Guests CSV file") do |g|
      options[:guests] = g
    end

    opts.on("-f", "--format FORMAT", "Output format") do |f|
      options[:format] = f
    end
  end.parse!

  börse = BettenBörse.new(options)
  assignments = börse.run_assignment
  if options[:format] == "csv"
    puts börse.generate_csv(assignments)
  else
    assignments.each do |assignment|
      puts assignment
      puts "---"
    end
    börse.print_statistics(assignments)
    puts ""
    puts "Unhoused visitors:"
    börse.homeless_guests(assignments).each do |guest|
      puts "#{Assignment.contact_to_s(guest)} requested #{Assignment.contact_period_to_s(guest)}"
      puts "\t#{Assignment.matching_options_to_s(guest)}"
    end
  end
end
