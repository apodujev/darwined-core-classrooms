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
    Classroom.delete_all
  end

  describe "GET ON /api/v1/classrooms" do
    it "should return all classrooms" do
      Classroom.create(:name => 'A', :capacity => 50)
      Classroom.create(:name => 'B', :capacity => 100)
      get '/api/v1/classrooms'
      last_response.should be_ok
      classrooms = JSON.parse(last_response.body)
      classrooms.should be_an_instance_of(Array)
      classrooms.length.should == 2
    end
  end

  describe "GET on /api/v1/classrooms/:id" do
    before(:each) do
      @classroom = Classroom.create(
        :name => 'A fine classroom',
        :capacity => 1000
      )
    end

    it "should return a classroom with name" do
      get "/api/v1/classrooms/#{@classroom.id}"
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)['classroom']
      attributes['name'].should == 'A fine classroom'
    end

    it "should return a classroom with capacity" do
      get "/api/v1/classrooms/#{@classroom.id}"
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)['classroom']
      attributes['capacity'].should == 1000
    end

    it "should return a 404 for a classroom that doesn't exist" do
      get '/api/v1/classrooms/12312'
      last_response.status.should == 404
    end
  end

  describe "POST on /api/v1/classrooms" do
    it "should create and return a classroom" do
      data = {
        :name       => 'classroom A',
        :capacity   => 45
      }
      post '/api/v1/classrooms', data.to_json
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)['classroom']
      attributes.should have_key("id")
      attributes['name'].should == 'classroom A'
      attributes['capacity'].should == 45
    end
  end

  describe "PUT on /api/v1/classrooms/:id" do
    it "should update a classroom" do
      @classroom = Classroom.create(
        :name     => 'Woopie',
        :capacity => 100
      )
      data = {
        :name     => 'Woopies',
        :capacity => 300
      }
      put "/api/v1/classrooms/#{@classroom.id}", data.to_json
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)['classroom']
      attributes['id'].should == @classroom.id
      attributes['name'].should == 'Woopies'
      attributes['capacity'].should == 300
    end
  end

  describe "DELETE on /api/v1/classrooms/:id" do
    it "should delete a post by id" do
      @classroom = Classroom.create(
        :name     => 'Woopie',
        :capacity => 50
      )
      delete "/api/v1/classrooms/#{@classroom.id}"
      last_response.should be_ok
      get "/api/v1/classroom/#{@classroom.id}"
      last_response.status.should == 404
    end
  end
end