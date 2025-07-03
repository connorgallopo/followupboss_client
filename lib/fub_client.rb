# Libs
require 'base64'
require 'singleton'
require 'logger'
require 'active_support'
require 'active_support/all'
require 'active_support/core_ext/hash/keys'
require 'faraday'
require 'fub_client/rails8_patch'  # Must be loaded after ActiveSupport and Faraday but before Her
require 'fub_client/her_patch'     # Must be loaded after Faraday but before Her
require 'facets/string/snakecase'
require 'multi_json'
require 'fub_client/compatibility'
require 'her'

# App
require 'fub_client/version'
require 'fub_client/configuration'
require 'fub_client/client'
require 'fub_client/cookie_client'
require 'fub_client/middleware'
require 'fub_client/middleware/cookie_authentication'
require 'fub_client/resource'
# App Models
require 'fub_client/event'
require 'fub_client/person'
require 'fub_client/note'
require 'fub_client/call'
require 'fub_client/user'
require 'fub_client/smart_list'
require 'fub_client/email_template'
require 'fub_client/action_plan'
require 'fub_client/em_event'
require 'fub_client/custom_field'
require 'fub_client/task'
require 'fub_client/property'
require 'fub_client/deal'
require 'fub_client/message'
require 'fub_client/appointment'
require 'fub_client/text_message'
require 'fub_client/stage'
require 'fub_client/pipeline'
require 'fub_client/webhook'
require 'fub_client/text_message_template'
require 'fub_client/people_relationship'
require 'fub_client/person_attachment'
require 'fub_client/team'
require 'fub_client/deal_custom_field'
require 'fub_client/deal_attachment'
require 'fub_client/group'
require 'fub_client/appointment_type'
require 'fub_client/appointment_outcome'
require 'fub_client/identity'
require 'fub_client/team_inbox'
require 'fub_client/shared_inbox'

module FubClient
  def self.root
    File.expand_path '..', __dir__
  end
end
