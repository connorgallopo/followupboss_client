#!/usr/bin/env ruby
require 'bundler/setup'
require 'fub_client'
require 'dotenv'
require 'pry'
Dotenv.load

# Load environment variables from .env file
EMAIL = ENV['FUB_EMAIL'] || 'your_email@example.com'
PASSWORD = ENV['FUB_PASSWORD'] || 'your_password'
SUBDOMAIN = ENV['FUB_SUBDOMAIN'] || 'your_subdomain'

# Set debug mode
ENV['DEBUG'] = 'true'

puts '-------------------------------------------'
puts 'Testing SharedInbox API with Cookie Auth'
puts '-------------------------------------------'

# Step 1: Login to obtain cookies
client = FubClient::Client.instance
login_success = client.login(EMAIL, PASSWORD)

if login_success
  puts '✅ Login successful! Cookies obtained.'
else
  puts '❌ Login failed! Cannot proceed.'
  exit 1
end

# Step 2: Setup cookie client with subdomain
client.subdomain = SUBDOMAIN
puts "💡 Set subdomain to: #{SUBDOMAIN}"

# Reset the HER API to apply the new settings
client.reset_her_api
puts '🔄 Reset the HER API connection with new settings'

# Add a breakpoint for debugging
puts "\n🔍 Debug point - inspect client state"
binding.pry

# Step 3: Get all shared inboxes
puts "\n📬 Fetching all shared inboxes..."
begin
  inboxes = FubClient::SharedInbox.all_inboxes
  puts "Found #{inboxes.count} shared inboxes"

  inboxes.each do |inbox|
    puts "  - Inbox ID: #{inbox.id}, Name: #{inbox.name}"
  end
rescue StandardError => e
  puts "❌ Error fetching shared inboxes: #{e.message}"
  puts 'Debugging error:'
  binding.pry
end

# Step 4: Get a specific shared inbox
puts "\n📬 Fetching shared inbox with ID 1..."
begin
  inbox = FubClient::SharedInbox.get_inbox(1)
  if inbox
    puts "✅ Found inbox: #{inbox.name}"

    # Get settings
    puts "\n⚙️ Fetching settings for inbox #{inbox.id}..."
    settings = inbox.settings
    puts "Settings: #{settings.inspect}"

    # Get conversations
    puts "\n💬 Fetching conversations for inbox #{inbox.id}..."
    conversations = inbox.conversations(5, 0)
    puts "Found #{conversations.count} conversations"

    # Get messages
    puts "\n📨 Fetching messages for inbox #{inbox.id}..."
    messages = inbox.messages(5, 0)
    puts "Found #{messages.count} messages"
  else
    puts '❌ Inbox with ID 1 not found'
  end
rescue StandardError => e
  puts "❌ Error fetching shared inbox: #{e.message}"
  puts 'Debugging error:'
  binding.pry
end

puts "\n-------------------------------------------"
puts 'Test completed!'
puts '-------------------------------------------'
