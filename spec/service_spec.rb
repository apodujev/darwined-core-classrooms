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
    Room.delete_all
  end

  describe "GET ON /api/v1/rooms" do
    it "should return all rooms" do
      Room.create(:name => 'A', :capacity => 50)
      Room.create(:name => 'B', :capacity => 100)
      get '/api/v1/rooms'
      last_response.should be_ok
      rooms = JSON.parse(last_response.body)
      rooms.should be_an_instance_of(Array)
      rooms.length.should == 2
    end
  end

  describe "GET on /api/v1/rooms/:id" do
    before(:each) do
      @room = Room.create(
        :name => 'A fine room',
        :capacity => 1000
      )
    end

    it "should return a room with name" do
      get "/api/v1/rooms/#{@room.id}"
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)["room"]
      attributes['name'].should == 'A fine room'
    end

    it "should return a room with capacity" do
      get "/api/v1/rooms/#{@room.id}"
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)["room"]
      attributes['capacity'].should == 1000
    end

    it "should return a 404 for a room that doesn't exist" do
      get '/api/v1/rooms/12312'
      last_response.status.should == 404
    end
  end

  describe "POST on /api/v1/rooms" do
    it "should create and return a room" do
      data = {
        :name       => 'room A',
        :capacity   => 45
      }
      post '/api/v1/rooms', data.to_json
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)['room']
      attributes.should have_key("id")
      attributes['name'].should == 'room A'
      attributes['capacity'].should == 45
    end
  end

  describe "PUT on /api/v1/rooms/:id" do
    it "should update a room" do
      @room = Room.create(
        :name     => 'Woopie',
        :capacity => 100
      )
      data = {
        :name     => 'Woopies',
        :capacity => 300
      }
      put "/api/v1/rooms/#{@room.id}", data.to_json
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)['room']
      attributes['id'].should == @room.id
      attributes['name'].should == 'Woopies'
      attributes['capacity'].should == 300
    end
  end

  describe "DELETE on /api/v1/rooms/:id" do
    it "should delete a post by id" do
      @room = Room.create(
        :name     => 'Woopie',
        :capacity => 50
      )
      delete "/api/v1/rooms/#{@room.id}"
      last_response.should be_ok
      get "/api/v1/room/#{@room.id}"
      last_response.status.should == 404
    end
  end
end