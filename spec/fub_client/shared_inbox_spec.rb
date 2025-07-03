require 'spec_helper'

describe FubClient::SharedInbox do
  let(:client) { FubClient::Client.instance }
  let(:inbox_id) { 1 }
  
  before do
    # Setup for cookie auth
    allow(client).to receive(:cookies).and_return('some_cookie=value')
    allow(client).to receive(:subdomain).and_return('jdouglasproperties')
    allow(client).to receive(:use_cookies?).and_return(true)
  end
  
  context 'with cookie authentication' do
    describe '.all_inboxes' do
      it 'fetches all shared inboxes' do
        VCR.use_cassette('shared_inboxes_all') do
          inboxes = described_class.all_inboxes
          expect(inboxes).to be_an(Array)
        end
      end
    end
    
    describe '.get_inbox' do
      it 'fetches a specific shared inbox by ID' do
        VCR.use_cassette('shared_inbox_get') do
          inbox = described_class.get_inbox(inbox_id)
          expect(inbox).to be_a(described_class)
          expect(inbox.id).to eq(inbox_id)
        end
      end
    end
    
    describe '#messages' do
      it 'fetches messages for a shared inbox' do
        inbox = described_class.new(id: inbox_id)
        
        VCR.use_cassette('shared_inbox_messages') do
          messages = inbox.messages
          expect(messages).to be_an(Array)
        end
      end
    end
    
    describe '#settings' do
      it 'fetches settings for a shared inbox' do
        inbox = described_class.new(id: inbox_id)
        
        VCR.use_cassette('shared_inbox_settings') do
          settings = inbox.settings
          expect(settings).to be_a(Hash)
        end
      end
    end
    
    describe '#conversations' do
      it 'fetches conversations for a shared inbox' do
        inbox = described_class.new(id: inbox_id)
        
        VCR.use_cassette('shared_inbox_conversations') do
          conversations = inbox.conversations
          expect(conversations).to be_an(Array)
        end
      end
    end
  end
end
