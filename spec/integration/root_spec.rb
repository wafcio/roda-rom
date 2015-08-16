require 'spec_helper'

RSpec.describe 'Root Requests' do
  include AppSetup

  describe 'GET /' do
    before { do_request }

    it 'responds with 200 HTTP code' do
      expect(last_response.status).to eq(302)
    end

    it 'returns proper message' do
      follow_redirect!
      expect(last_response.body).to eq('OK')
    end
  end

  private
  def do_request
    get '/'
  end
end
