require "http"
require "json"
require "ascii_charts"

puts "What is your location?"
location = gets.chomp

gmaps_key = ENV.fetch("GMAPS_KEY")
gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{location}&key=#{gmaps_key}"

gmaps_data = HTTP.get(gmaps_url)
parsed_gmaps_data = JSON.parse(gmaps_data)
gmaps_results_array = parsed_gmaps_data.fetch("results")
first_result_hash = gmaps_results_array.at(0)
geometry_hash = first_result_hash.fetch("geometry")
location_hash = geometry_hash.fetch("location")

latitude = location_hash.fetch("lat")
longitude = location_hash.fetch("lng")

puts "Your coordinates are Lat: #{latitude}, Long: #{longitude}"

pirates_key = ENV.fetch("PIRATE_WEATHER_KEY")
pirates_url = "https://api.pirateweather.net/forecast/#{pirates_key}/#{latitude},#{longitude}"

pirates_data = HTTP.get(pirates_url)
parsed_pirates_data = JSON.parse(pirates_data)

currently_hash = parsed_pirates_data.fetch("currently")
current_temp = currently_hash.fetch("temperature")

puts "It is currently #{current_temp} degrees fahrenheit"

minutely_hash = parsed_pirates_data.fetch("minutely",false)
if(minutely_hash)
  next_hour_summary = minutely_hash.fetch("summary")
  puts "Next hour: #{next_hour_summary}"
end

hourly_hash = parsed_pirates_data.fetch("hourly")
hourly_data_array = hourly_hash.fetch("data")

next_twelve_hours = hourly_data_array[1..12]
precipitation = false

chart_data = []

next_twelve_hours.each do |hour|
  precipitation_pos = hour.fetch("precipProbability")
  precip_time = Time.at(hour.fetch("time"))
  seconds_from_now = precip_time - Time.now
  hours_from_now = seconds_from_now / 60 / 60
  chart_data.push([hours_from_now.round,(precipitation_pos*100).round])
  if(precipitation_pos > 0.1)
    precipitation = true
    puts "In #{hours_from_now.round} hours there is a #{(precipitation_pos*100).round}% chance of precipitation"
  end
end

if(precipitation)
  
  puts AsciiCharts::Cartesian.new(chart_data,:bar => true, :title => 'Precipitation').draw

  puts "You might want to carry an umbrella!"
else
  puts "You probably won’t need an umbrella today."
end
