#!/usr/bin/env ruby
require 'open3'

puts "-------------------------------------------"
puts "Testing direct curl for shared inbox API"
puts "-------------------------------------------"

# Use the exact curl command from the example
subdomain = "***REMOVED***"
cookie_string = "***REMOVED***; ***REMOVED***|68fd4e278b8921bb84f6f614d2e72528; _fbp=fb.1.1745264289069.185198969320878588; cf_1859_id=e9ad6eb8-8497-463a-acaa-db07bf0b2d38; WidgetTrackerCookie=6daa7fbf-8ac3-47da-8c54-a2645912be4b; hubspotutk=b5e239d5b44765f81af204da4ccb5e05; rdtb=420c26f491821a3bc715257ac4b646b3af81e14b38c7ea102c64001d0165e423; intercom-device-id-mfhsavoz=3a9938f4-f196-41d3-a5f0-80b2a5d770e4; NPS_b227f015_last_seen=1745264294530; __stripe_mid=b0049c62-c99a-47f5-a039-db0a06214cc079858d; ***REMOVED***; __hssrc=1; _vwo_uuid=D4B42442498CE389B4BE976B6ACD4914A; _vwo_ds=3%241745849892%3A10.77596839%3A%3A; _vis_opt_s=1%7C; _vis_opt_test_cookie=1; _vis_opt_exp_39_combi=1; _gcl_aw=GCL.1746192459.Cj0KCQjw2tHABhCiARIsANZzDWrMhHDVmqLkjV5dlVOK9lOru8AtDyQ07Zqc8HZdn7AjaPkyj1jXvcsaAhHqEALw_wcB; _gcl_gs=2.1.k1$i1746192457$u220191118; _gac_UA-26653653-1=1.1746192459.Cj0KCQjw2tHABhCiARIsANZzDWrMhHDVmqLkjV5dlVOK9lOru8AtDyQ07Zqc8HZdn7AjaPkyj1jXvcsaAhHqEALw_wcB; ***REMOVED***; _ga_J70LJ0E97T=GS2.1.s1746643928$o3$g1$t1746643945$j0$l0$h0; _clck=nemvia%7C2%7Cfvr%7C0%7C1937; rdpl_subdomain=***REMOVED***; _uetvid=276d41c01ee811f0b689830248da280b; _ga=GA1.1.172799480.1745264289; cf_1859_person_time=1746815831087; cf_1859_person_last_update=1746815831088; __hstc=134341614.b5e239d5b44765f81af204da4ccb5e05.1745264290477.1746804223967.1746815831499.9; _ga_CTHYBY0K29=GS2.1.s1746815830$o10$g0$t1746815831$j59$l0$h1105890760; ***REMOVED***0402d0885a8343c964108e40d5b6f50a20b061b5b7f9b997b4db16e6; rdpl2=c3b3ed45cad27e755461fa2ce5ecec26d0a54ae31aaee4e8907767831b4a2a43; NPS_b227f015_throttle=1747098551527; __stripe_sid=e3b38a9f-3a73-4ebc-a9c4-3d5a649891d594ae47; intercom-session-mfhsavoz=TUZxd09QRzd5bVl3VnhSdmNLZHBCdUJvSzJxUmEzL0ZjRk9jd0hLSFh5VWNSaFoyM0pnd1E5QitFNkhFaUhCZWY2MmpEK1hYWWRxTzNXRmtvS0c3RGY2RWM2ajdYRXpBSVp4V0tSRDZsWGc9LS1wb1I0VzhZL2EyWGUzQ1oydGtTUENBPT0=--070ebda94d469d09b6ae38729993ff7babbf6176; fs_lua=1.1747065778427; ***REMOVED***:d9561c73-2dea-4b6b-beaa-14efe3aab227:1747064800265::2#a677ec8f#/1778257559"

# Build exact curl command from the example
cmd = "curl -s 'https://#{subdomain}.followupboss.com/api/v1/sharedInboxes?showAllBypass=true&limit=20&offset=0' " +
      "-H 'accept: application/json, text/javascript, */*; q=0.01' " +
      "-H 'accept-language: en-US,en;q=0.9' " +
      "-H 'x-requested-with: XMLHttpRequest' " +
      "-H 'x-system: fub-spa' " +
      "-H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36' " +
      "-b '#{cookie_string}'"

puts "\n🔄 Executing curl command..."
puts "Command: #{cmd}\n\n"

stdout, stderr, status = Open3.capture3(cmd)

if status.success?
  puts "✅ Curl command executed successfully"
  
  # Pretty print the JSON response
  require 'json'
  begin
    response = JSON.parse(stdout)
    puts "\nResponse (#{response.class}):"
    puts JSON.pretty_generate(response)
    
    if response.is_a?(Hash) && response["sharedInboxes"]
      puts "\nFound #{response["sharedInboxes"].length} shared inboxes"
    elsif response.is_a?(Array)
      puts "\nFound #{response.length} shared inboxes"
    else
      puts "\nUnexpected response format"
    end
  rescue JSON::ParserError => e
    puts "Error parsing JSON response: #{e.message}"
    puts "Raw response: #{stdout}"
  end
else
  puts "❌ Curl command failed with error: #{stderr}"
end

puts "\n-------------------------------------------"
puts "Test completed!"
puts "-------------------------------------------"
