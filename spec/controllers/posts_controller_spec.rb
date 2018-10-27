require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:user)    { create :user }
  let!(:posts)  { create_list :post, 150, user: user }

  it 'gets list of users' do
    get :index, params: { page: { number: 2 } }
    expect(response.status).to eq 200
    expect(response.content_type).to eq 'application/vnd.api+json'
    jdata = JSON.parse response.body
    expect(jdata['data'].length).to eql Post.per_page
    expect(jdata['data'][0]['type']).to eql 'posts'
    expect(jdata['meta']['total-count']).to eql Post.count
    links = jdata['links']
    expect(links['first']).to eql links['prev']
    expect(links['last']).to eql links['next']
  end

end
