RSpec.describe Api::V1::PerformanceDataController, type: :request do
  let(:user) { FactoryGirl.create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }
  let(:headers_sad) { { HTTP_ACCEPT: 'application/json' } }

  describe 'POST /api/v1/performance_data' do
    it 'creates a data entry' do
      post '/api/v1/performance_data', params: {
        performance_data: { data: { message: 'Average' } }
      }, headers: headers
      entry = PerformanceData.last
      expect(entry.data).to eq 'message' => 'Average'
      expect(response_json['message']).to eq 'all good'
    end

    it 'fails to create data entry no user is present' do
      user = PerformanceData.create(data: { message: 'Average' })
      expect(user.errors.full_messages).to eq ['User must exist']
    end

    it 'gives error message if no user is present' do
      post '/api/v1/performance_data', params: {
        performance_data: { data: { message: 'Average' } }
      }, headers: headers_sad
      expect(response_json["errors"]).to eq ["You need to sign in or sign up before continuing."]
    end
  end

  describe 'GET /api/v1/performance_data' do
    before do
      5.times { user.performance_data.create(data: { message: 'Average' }) }
    end

    it 'returns a collection of performance data' do
      get '/api/v1/performance_data', headers: headers
      expect(response_json['entries'].count).to eq 5
    end
  end
end
