require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'


def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_phonenumber(phone)
    phone.gsub!(/[^\d]/,'')
    if phone.length == 10
        phone
    elsif phone.length == 11 && phone[0] == '1'
        phone[1..10]
    else
        'Wrong Number'
    end
end


puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter
hours = []
days = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])

  phone = clean_phonenumber(row[:homephone])
  
  date = Time.strptime(row[:regdate],"%m/%d/%y %H:%M")
  hours.push(date.hour)
  days.push(date.strftime('%A'))
  #legislators = legislators_by_zipcode(zipcode)

  #form_letter = erb_template.result(binding)

  #phone = row[:homephone]
  
  #save_thank_you_letter(id,form_letter)
end

most_hours = hours.max_by{|h| hours.count(h)}

most_days = days.max_by{|day| days.count(day) }
puts "Most common registration hour is #{most_hours}:00"
puts "Most common registration day is #{most_days}"