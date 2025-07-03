# FollowUpBoss Client - Enhanced Ruby client for Follow Up Boss API
#
# This gem provides Rails 8 compatibility, secure cookie authentication,
# and comprehensive API coverage for the Follow Up Boss CRM.
#
# Usage:
#   require 'followupboss_client'
#
#   FubClient.configure do |config|
#     config.api_key = 'your_api_key'
#   end
#
#   people = FubClient::Person.all
#   deals = FubClient::Deal.active

require_relative 'fub_client'
