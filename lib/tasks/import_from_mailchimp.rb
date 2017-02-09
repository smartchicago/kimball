require_relative '../../config/environment'

require 'csv'
require 'optparse'

$stdout.sync = false

class MailChimpImporter

  @options = {}

  def initialize(opts)
    @options = opts
  end

  # FIXME: Refactor and re-enable cop
  # rubocop:disable Metrics/MethodLength
  #
  def load_mailchimp_csv
    $stdout.puts 'loading mailchimp data'
    count = 0

    CSV.foreach(@options.mailchimp_infile, headers: :first_row) do |line|
      person = Person.new
      column_map = {
        'Email Address' => :email_address, 'First Name' => :first_name, 'Last Name' => :last_name, 'Ward' => :geography_id, 'ZIP Code' => :postal_code,
        'How would you like to participate' => :participation_type, 'Primary device' => :primary_device_id, 'Primary device description' => :primary_device_description,
        'Secondary device' => :secondary_device_id, 'Secondary device description' => :secondary_device_description, 'Primary connection method' => :primary_connection_id,
        'Connection method description' => :primary_connection_description, 'Did you vote in the most recent election' => :voted, 'Have you ever called 311' => :called_311,
        'CONFIRM_TIME' => :signup_at
      }

      column_map.each do |k, v|
        person[v] = if k == 'Primary device' || k == 'Secondary device'
                      Person.map_device_to_id(line[k])
                    elsif k == 'Primary connection method'
                      Person.map_connection_to_id(line[k])
                    else
                      line[k]
                    end
      end

      Rails.logger.info "[load_mailchimp_csv] saving a new person: #{line['Email']}"

      person.save
      $stdout.print '.'
      count += 1
    end
    $stdout.puts "\ncompleted mailchimp import, #{count} records"
  end
  # rubocop:enable Metrics/MethodLength

  # FIXME: Refactor and re-enable cop
  # rubocop:disable Metrics/MethodLength
  #
  def load_wufoo_csv
    $stdout.puts 'starting wufoo import'
    count = 0
    CSV.foreach(@options.wufoo_infile, headers: :first_row) do |line|
      person = Person.find_by(email_address: line['Email'])

      if person.blank?
        $stderr.puts("\n[load_wufoo_csv] skipping import of #{line['Email']}")
        next
      end

      person.address_1 = line['Address']
      person.phone_number = line['Phone Number']
      person.postal_code = line['Zip code']
      person.city = 'Chicago'
      person.state = 'Illinois'
      person.signup_ip = line['IP Address']

      Rails.logger.info "[load_wufoo_csv] saving wufoo data: #{line['Email']}"

      person.save
      $stdout.print '.'
      count += 1
    end

    $stdout.puts "\ncompleted wufoo import, #{count} records"
  end
  # rubocop:enable Metrics/MethodLength

  # FIXME: Refactor and re-enable cop
  # rubocop:disable Rails/Output
  #
  def run
    if @options[:reset]
      puts 'Destroying all existing records'
      Person.delete_all
    end

    load_mailchimp_csv
    load_wufoo_csv
  end
  # rubocop:enable Rails/Output

end

options = OpenStruct.new
OptionParser.new do |opts|
  options.dryrun = false
  options.reset  = false

  opts.banner = 'Usage: import_from_mailchimp.rb [options]'

  opts.on('-i', '--mc-infile FILE', 'Input CSV') do |v|
    options.mailchimp_infile = v
  end

  opts.on('-w', '--wufoo-infile FILE', 'Wufoo Input CSV') do |v|
    options.wufoo_infile = v
  end

  opts.on('-d', '--[no-]dry-run', 'Dry run (if present will not commit changes)') do |_v|
    options.dryrun = true
  end

  opts.on('-r', '--reset', 'Reset database') do |_v|
    options.reset = true
  end
end.parse!

MailChimpImporter.new(options).run
