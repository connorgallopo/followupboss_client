#!/usr/bin/env ruby
require 'bundler/setup'
require 'fub_client'
require 'dotenv'
require 'pry'
Dotenv.load

# Set debug mode
ENV['DEBUG'] = 'true'

puts "-------------------------------------------"
puts "Testing SharedInbox API with Gist Cookie"
puts "-------------------------------------------"

# Step 1: Initialize client with hardcoded working cookie
subdomain = ENV['FUB_SUBDOMAIN'] || '***REMOVED***'
puts "💡 Set subdomain to: #{subdomain}"

# Use the exact cookie string from the working curl example
working_cookie = "***REMOVED***; ***REMOVED***|68fd4e278b8921bb84f6f614d2e72528; _fbp=fb.1.1745264289069.185198969320878588; cf_1859_id=e9ad6eb8-8497-463a-acaa-db07bf0b2d38; WidgetTrackerCookie=6daa7fbf-8ac3-47da-8c54-a2645912be4b; hubspotutk=b5e239d5b44765f81af204da4ccb5e05; rdtb=420c26f491821a3bc715257ac4b646b3af81e14b38c7ea102c64001d0165e423; intercom-device-id-mfhsavoz=3a9938f4-f196-41d3-a5f0-80b2a5d770e4; NPS_b227f015_last_seen=1745264294530; __stripe_mid=b0049c62-c99a-47f5-a039-db0a06214cc079858d; ***REMOVED***; __hssrc=1; _vwo_uuid=D4B42442498CE389B4BE976B6ACD4914A; _vwo_ds=3%241745849892%3A10.77596839%3A%3A; _vis_opt_s=1%7C; _vis_opt_test_cookie=1; _vis_opt_exp_39_combi=1; _gcl_aw=GCL.1746192459.Cj0KCQjw2tHABhCiARIsANZzDWrMhHDVmqLkjV5dlVOK9lOru8AtDyQ07Zqc8HZdn7AjaPkyj1jXvcsaAhHqEALw_wcB; _gcl_gs=2.1.k1$i1746192457$u220191118; _gac_UA-26653653-1=1.1746192459.Cj0KCQjw2tHABhCiARIsANZzDWrMhHDVmqLkjV5dlVOK9lOru8AtDyQ07Zqc8HZdn7AjaPkyj1jXvcsaAhHqEALw_wcB; ***REMOVED***; _ga_J70LJ0E97T=GS2.1.s1746643928$o3$g1$t1746643945$j0$l0$h0; _clck=nemvia%7C2%7Cfvr%7C0%7C1937; rdpl_subdomain=***REMOVED***; _uetvid=276d41c01ee811f0b689830248da280b; _ga=GA1.1.172799480.1745264289; cf_1859_person_time=1746815831087; cf_1859_person_last_update=1746815831088; __hstc=134341614.b5e239d5b44765f81af204da4ccb5e05.1745264290477.1746804223967.1746815831499.9; _ga_CTHYBY0K29=GS2.1.s1746815830$o10$g0$t1746815831$j59$l0$h1105890760; ***REMOVED***0402d0885a8343c964108e40d5b6f50a20b061b5b7f9b997b4db16e6; rdpl2=c3b3ed45cad27e755461fa2ce5ecec26d0a54ae31aaee4e8907767831b4a2a43; NPS_b227f015_throttle=1747098551527; __stripe_sid=e3b38a9f-3a73-4ebc-a9c4-3d5a649891d594ae47; intercom-session-mfhsavoz=TUZxd09QRzd5bVl3VnhSdmNLZHBCdUJvSzJxUmEzL0ZjRk9jd0hLSFh5VWNSaFoyM0pnd1E5QitFNkhFaUhCZWY2MmpEK1hYWWRxTzNXRmtvS0c3RGY2RWM2ajdYRXpBSVp4V0tSRDZsWGc9LS1wb1I0VzhZL2EyWGUzQ1oydGtTUENBPT0=--070ebda94d469d09b6ae38729993ff7babbf6176; fs_lua=1.1747065778427; ***REMOVED***:d9561c73-2dea-4b6b-beaa-14efe3aab227:1747064800265::2#a677ec8f#/1778257559"

puts "🍪 Using working cookie from curl example (#{working_cookie.length} chars)"

# Create the client and set the known working cookie
client = FubClient::Client.instance
client.cookies = working_cookie 
client.subdomain = subdomain
client.reset_her_api

puts "✅ Client set up with working cookie"

# Add a breakpoint for debugging
puts "\n🔍 Debug point - inspect client state"
binding.pry if ENV['DEBUG_PRY']

# Note: With our new implementation, we no longer need to set the client as an instance
# The cookie client now automatically delegates to the Client.instance
puts "🔄 Using cookie client with Client.instance"

# Step 3: Get all shared inboxes
puts "\n📬 Fetching all shared inboxes..."
begin
  inboxes = FubClient::SharedInbox.all_inboxes
  puts "Found #{inboxes.count} shared inboxes"
  
  inboxes.each do |inbox|
    # Handle both Hash objects (from direct Faraday) and model objects (from Her)
    if inbox.is_a?(Hash)
      puts "  - Inbox ID: #{inbox[:id]}, Name: #{inbox[:name]}"
    else
      puts "  - Inbox ID: #{inbox.id}, Name: #{inbox.name}"
    end
  end
rescue => e
  puts "❌ Error fetching shared inboxes: #{e.message}"
  puts e.backtrace.join("\n") if ENV['DEBUG']
  puts "Debugging error:"
  binding.pry if ENV['DEBUG_PRY']
end

# Step 4: Get a specific shared inbox
puts "\n📬 Fetching first shared inbox..."
begin
  if inboxes && inboxes.first
    # Get the ID - handle both Hash objects and model objects
    inbox_id = inboxes.first.is_a?(Hash) ? inboxes.first[:id] : inboxes.first.id
    
    puts "Looking up inbox with ID: #{inbox_id}"
    # Get the inbox using the direct get_inbox method
    inbox = FubClient::SharedInbox.get_inbox(inbox_id)
    
    if inbox
      # Display inbox info - handle both Hash objects and model objects
      if inbox.is_a?(Hash)
        puts "✅ Found inbox: #{inbox[:name]} (ID: #{inbox[:id]})"
      else
        puts "✅ Found inbox: #{inbox.name} (ID: #{inbox.id})"
      end
      
      # Displaying info that we have in the hash
      puts "\n📋 Inbox details:"
      if inbox.is_a?(Hash)
        puts "  - Created: #{inbox[:created]}"
        puts "  - Updated: #{inbox[:updated]}"
        puts "  - Status: #{inbox[:status]}"
        puts "  - Type: #{inbox[:type]}"
        
        if inbox[:phones] && !inbox[:phones].empty?
          puts "  - Phones:"
          inbox[:phones].each do |phone|
            puts "    * #{phone[:phone]} (Can text: #{phone[:canText] ? 'Yes' : 'No'})"
          end
        end
        
        if inbox[:users] && !inbox[:users].empty?
          puts "  - Users:"
          inbox[:users].each do |user|
            puts "    * #{user[:name]} (#{user[:role]})"
          end
        end
      end
      
      # Get settings
      puts "\n⚙️ Fetching settings for inbox..."
      begin
        settings = inbox.settings
        if settings && !settings.empty?
          puts "✅ Settings retrieved successfully"
          puts "Settings sample: #{settings.inspect[0..100]}..." if settings.inspect.length > 100
        else
          puts "No settings found or empty settings"
        end
      rescue => e
        puts "❌ Error fetching settings: #{e.message}"
      end
      
      # Get conversations
      puts "\n💬 Fetching conversations for inbox..."
      begin
        conversations = inbox.conversations(5, 0)
        if conversations && !conversations.empty?
          puts "✅ Found #{conversations.count} conversations"
          if ENV['DEBUG'] && conversations.first
            conv = conversations.first
            if conv.is_a?(Hash)
              puts "First conversation: ID #{conv[:id]}, Subject: #{conv[:subject]}"
            else
              puts "First conversation: ID #{conv.id}, Subject: #{conv.subject}"
            end
          end
        else
          puts "No conversations found or empty conversations"
        end
      rescue => e
        puts "❌ Error fetching conversations: #{e.message}"
      end
      
      # Get messages
      puts "\n📨 Fetching messages for inbox..."
      begin
        messages = inbox.messages(5, 0)
        if messages && !messages.empty?
          puts "✅ Found #{messages.count} messages"
          if ENV['DEBUG'] && messages.first
            msg = messages.first
            if msg.is_a?(Hash)
              puts "First message: ID #{msg[:id]}, From: #{msg[:from]}"
            else
              puts "First message: ID #{msg.id}, From: #{msg.from}"
            end
          end
        else
          puts "No messages found or empty messages"
        end
      rescue => e
        puts "❌ Error fetching messages: #{e.message}"
      end
    else
      puts "❌ Inbox with ID #{inbox_id} not found"
    end
  else
    puts "❌ No inboxes found to test with"
  end
rescue => e
  puts "❌ Error fetching shared inbox: #{e.message}"
  puts e.backtrace.join("\n") if ENV['DEBUG']
  puts "Debugging error:"
  binding.pry if ENV['DEBUG_PRY']
end

puts "\n-------------------------------------------"
puts "Test completed!"
puts "-------------------------------------------"
