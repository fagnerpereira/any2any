require_relative 'lib/erb2slim'
source = "<div><%= 'hello' %></div>"
begin
  result = Erb2Slim.convert(source)
  puts "Result: #{result[:output]}"
  if result[:output].include?("div") && result[:output].include?("hello")
    puts "Verification SUCCESS"
  else
    puts "Verification FAILURE: Output unexpected"
  end
rescue => e
  puts "Verification ERROR: #{e.message}"
  puts e.backtrace
end
