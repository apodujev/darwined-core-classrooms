# Ensure env is set to `test`
ENV['RACK_ENV'] = ENV['SINATRA_ENV'] = 'test'

require_relative '../service'
require 'rspec'
require 'rack/test'

# Configure RSpec to use rack-test methods
RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

# Which sinatra app to use (classic style, in this case)
def app
  Sinatra::Application
end

# The test for our service
describe "service" do
  before(:each) do
    Post.delete_all
  end

  describe "GET ON /api/v1/posts" do
    it "should return all posts" do
      Post.create(:title => 'A', :body => 'A')
      Post.create(:title => 'B', :body => 'B')
      get '/api/v1/posts'
      last_response.should be_ok
      posts = JSON.parse(last_response.body)
      posts.should be_an_instance_of(Array)
      posts.length.should == 2
    end
  end

  describe "GET on /api/v1/posts/:id" do
    before(:each) do
      @post = Post.create(
        :title => 'A fine tittle',
        :body => 'A not so long body'
      )
    end

    it "should return a post with title" do
      get "/api/v1/posts/#{@post.id}"
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)["post"]
      attributes['title'].should == 'A fine tittle'
    end

    it "should return a post with a body" do
      get "/api/v1/posts/#{@post.id}"
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)["post"]
      attributes['body'].should == 'A not so long body'
    end

    it "should return a 404 for a user that doesn't exist" do
      get '/api/v1/posts/12312'
      last_response.status.should == 404
    end
  end

  describe "POST on /api/v1/posts" do
    it "should create and return a post" do
      data = {
        :title => "trotter",
        :body  => "no spam"
      }
      post '/api/v1/posts', data.to_json
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)['post']
      attributes.should have_key("id")
      attributes['title'].should == 'trotter'
      attributes['body'].should == 'no spam'
    end
  end

  describe "PUT on /api/v1/posts/:id" do
    it "should update a post" do
      @post = Post.create(
        :title => 'Woopie',
        :body => 'Long ago...'
      )
      data = {
        :title => 'Woopies',
        :body => 'Not so long ago...'
      }
      put "/api/v1/posts/#{@post.id}", data.to_json
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)['post']
      attributes['id'].should == @post.id
      attributes['title'].should == 'Woopies'
      attributes['body'].should == 'Not so long ago...'
    end
  end

  describe "DELETE on /api/v1/posts/:id" do
    it "should delete a post by id" do
      @post = Post.create(
        :title => 'Woopie',
        :body => 'Long ago...'
      )
      delete "/api/v1/posts/#{@post.id}"
      last_response.should be_ok
      get "/api/v1/posts/#{@post.id}"
      last_response.status.should == 404
    end
  end
end