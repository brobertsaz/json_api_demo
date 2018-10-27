# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let!(:users) { create_list :user, 5 }
  let(:user) { create :user }

  it 'gets list of users' do
    get :index
    expect(response.status).to eq 200
    expect(response.content_type).to eq 'application/vnd.api+json'
    jdata = JSON.parse response.body
    expect(jdata['data'].length).to eql 5
    expect(jdata['data'][0]['type']).to eql 'users'
  end

  it 'gets valid user data' do
    get :show, params: { id: user.id }
    expect(response.status).to eq 200
    jdata = JSON.parse response.body
    expect(jdata['data']['id']).to eql user.id.to_s
  end

  it 'gets error with invalid user data' do
    get :show, params: { id: 'abc' }
    expect(response.status).to eq 404
    jdata = JSON.parse response.body
    expect(jdata['errors'][0]['detail']).to eql 'Wrong ID provided'
    expect(jdata['errors'][0]['source']['pointer']).to eql '/data/attributes/id'
  end

  context 'creating new user' do
    it 'fails without content type' do
      post :create, params: {}
      expect(response.status).to eq 406
    end

    it 'fails without api-key' do
      @request.headers['Content-Type'] = 'application/vnd.api+json'
      post :create, params: {}
      expect(response.status).to eq 403
    end

    it 'fails with incorrect api-key' do
      @request.headers['Content-Type'] = 'application/vnd.api+json'
      @request.headers['X-Api-Key'] = '0000'
      post :create, params: {}
      expect(response.status).to eq 403
    end

    it 'fails with invalid type' do
      @request.headers['Content-Type'] = 'application/vnd.api+json'
      @request.headers['X-Api-Key'] = user.token
      post :create, params: { data: { type: 'posts' } }
      expect(response.status).to eq 409
    end

    it 'fails with invalid data' do
      @request.headers['Content-Type'] = 'application/vnd.api+json'
      @request.headers['X-Api-Key'] = user.token
      post :create, params: {
        data: {
          type: 'users',
          attributes: {
            full_name: nil,
            password: nil,
            password_confirmation: nil
          }
        }
      }
      expect(response.status).to eq 422
      jdata = JSON.parse response.body
      pointers = jdata['errors'].collect { |e|
        e['source']['pointer'].split('/').last
      }.sort
      expect(pointers).to eql ['full-name','password']
    end

    it 'succeeds with valid data' do
      @request.headers['Content-Type'] = 'application/vnd.api+json'
      @request.headers['X-Api-Key'] = user.token
      post :create, params: {
        data: {
          type: 'users',
          attributes: {
            full_name: 'Bob Roberts',
            password: 'password',
            password_confirmation: 'password'
          }
        }
      }
      expect(response.status).to eq 201
      jdata = JSON.parse response.body
      expect(jdata['data']['attributes']['full-name']).to eql 'Bob Roberts'
    end
  end
end
