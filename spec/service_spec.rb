# Ensure env is set to `test`
ENV['RACK_ENV'] = ENV['SINATRA_ENV'] = 'test'

require File.join(File.dirname(__FILE__), 'spec_helper')
require 'sinatra/activerecord/rake'
require 'rack/test'
require File.join(File.dirname(__FILE__), '..', 'service')

# Configure RSpec to use rack-test methods
RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

# Which sinatra app to use (classic style, in this case)
def app
  Sinatra::Application
end

# Silence AR
ActiveRecord::Base.logger.level = 2 # don't log debug or info

# Drop test database and load again
File.delete('db/test.sqlite3') if File.exist?('db/test.sqlite3')
Rake::Task["db:schema:load"].invoke

# The test for our service
describe "service" do
  before(:each) do
    Classroom.delete_all
  end

  describe "GET ON /classrooms" do
    it "should return all classrooms" do
      Classroom.create(:name => 'A', :capacity => 50)
      Classroom.create(:name => 'B', :capacity => 100)
      get '/classrooms'
      last_response.should be_ok
      classrooms = JSON.parse(last_response.body)
      classrooms.should be_an_instance_of(Array)
      classrooms.length.should == 2
    end
  end

  describe "GET on /classrooms/:id" do
    before(:each) do
      @classroom = Classroom.create(
        :name => 'A fine classroom',
        :capacity => 1000,
        :code => 'A102'
      )
    end

    it "should return a classroom with name" do
      get "/classrooms/#{@classroom.id}"
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)['classroom']
      attributes['name'].should == 'A fine classroom'
    end

    it "should return a classroom with capacity" do
      get "/classrooms/#{@classroom.id}"
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)['classroom']
      attributes['capacity'].should == 1000
    end

    it "should return a classroom with code" do
      get "/classrooms/#{@classroom.id}"
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)['classroom']
      attributes['code'].should == 'A102'
    end

    it "should return a 404 for a classroom that doesn't exist" do
      get '/classrooms/12312'
      last_response.status.should == 404
    end
  end

  describe "POST on /classrooms" do
    it "should create and return a classroom" do
      data = {
        :name       => 'classroom A',
        :capacity   => 45,
        :code       => 'E405'
      }
      post '/classrooms', data.to_json
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)['classroom']
      attributes.should have_key("id")
      attributes['name'].should == 'classroom A'
      attributes['capacity'].should == 45
      attributes['code'].should == 'E405'
    end
  end

  describe "PUT on /classrooms/:id" do
    it "should update a classroom" do
      @classroom = Classroom.create(
        :name     => 'Woopie',
        :capacity => 100
      )
      data = {
        :name     => 'Woopies',
        :capacity => 300,
        :code     => 'T607'
      }
      put "/classrooms/#{@classroom.id}", data.to_json
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)['classroom']
      attributes['id'].should == @classroom.id
      attributes['name'].should == 'Woopies'
      attributes['capacity'].should == 300
      attributes['code'].should == 'T607'
    end
  end

  describe "DELETE on /classrooms/:id" do
    it "should delete a post by id" do
      @classroom = Classroom.create(
        :name     => 'Woopie',
        :capacity => 50
      )
      delete "/classrooms/#{@classroom.id}"
      last_response.should be_ok
      get "/classroom/#{@classroom.id}"
      last_response.status.should == 404
    end
  end
end