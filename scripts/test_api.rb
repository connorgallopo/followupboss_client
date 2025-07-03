#!/usr/bin/env ruby
require 'bundler/setup'
require 'fub_client'
require 'dotenv'
require 'pp'

# Load environment variables from .env file
Dotenv.load

# Print API key (masked for security)
api_key = ENV['FUB_API_KEY']
if api_key
  puts "Using API key: #{api_key[0..3]}...#{api_key[-4..-1]}"
else
  puts 'ERROR: No API key found in environment. Make sure you have FUB_API_KEY set in your .env file.'
  exit 1
end

# Helper function to test an endpoint
def test_endpoint(model_class, description = nil)
  description ||= model_class.name.split('::').last.downcase
  puts "\n===================================="
  puts "Testing #{model_class.name}.all (#{description})..."
  puts '===================================='

  begin
    puts 'Making API request...'
    response = model_class.all

    puts "\n=== Response Object Type ==="
    puts response.class

    if response.nil?
      puts "\n=== Response is nil ==="
    elsif response.respond_to?(:empty?) && response.empty?
      puts "\n=== Response is empty array ==="
    else
      count = response.respond_to?(:length) ? response.length : 'N/A'
      puts "\n=== Got #{count} results ==="

      if response.respond_to?(:first) && response.first
        puts "\n=== First result ==="
        pp response.first
      end
    end

    true
  rescue StandardError => e
    puts "\n=== ERROR ==="
    puts "#{e.class}: #{e.message}"
    puts e.backtrace[0..5]
    false
  end
end

# Test multiple endpoints
success = true

# Test People endpoint
success = test_endpoint(FubClient::Person) && success

# Test Users endpoint
success = test_endpoint(FubClient::User) && success

# Test Events endpoint
success = test_endpoint(FubClient::Event) && success

# Test newly added endpoints
puts "\n===================================="
puts 'Testing newly added endpoints...'
puts '===================================='

# Test Tasks endpoint
success = test_endpoint(FubClient::Task, 'tasks') && success

# Test Properties endpoint
success = test_endpoint(FubClient::Property, 'properties') && success

# Test Deals endpoint
success = test_endpoint(FubClient::Deal, 'deals') && success

# Test Messages endpoint
success = test_endpoint(FubClient::Message, 'messages') && success

# Test pagination with Events
puts "\n===================================="
puts 'Testing FubClient::Event.by_page (pagination)...'
puts '===================================='
begin
  puts 'Making API request with pagination...'
  response = FubClient::Event.by_page(1, 5)

  puts "\n=== Response Metadata ==="
  if response.respond_to?(:metadata) && response.metadata
    pp response.metadata
  else
    puts 'No metadata available'
  end

  puts "\n=== Got #{response.length} results with pagination ===" if response.respond_to?(:length)
rescue StandardError => e
  puts "\n=== ERROR (Pagination) ==="
  puts "#{e.class}: #{e.message}"
  puts e.backtrace[0..5]
  success = false
end

puts "\n===================================="
puts "SUMMARY: All tests #{success ? 'PASSED ✓' : 'FAILED ✗'}"
puts '===================================='
