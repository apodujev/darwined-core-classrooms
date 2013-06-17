require 'sinatra'
require 'sinatra/activerecord'
require './environments'
require './models/classroom'

# Set Content-Type for all requests
before do
  content_type 'application/json'
end

# the HTTP entry points to our service

# get all classrooms
get '/classrooms' do
  Classroom.all.to_json
end

# get a classroom by id
get '/classrooms/:id' do
  classroom = Classroom.find_by_id(params[:id])
  if classroom
    classroom.to_json
  else
    error 404, {:error => "classroom not found"}.to_json
  end
end

# create a classroom
post '/classrooms' do
  begin
    classroom = Classroom.create(JSON.parse(request.body.read))
    if classroom.valid?
      classroom.to_json
    else
      error 400, classroom.errors.to_json # :bad_request
    end
  rescue => e
    error 400, {:error => e.message}.to_json
  end
end

# update a classroom
put '/classrooms/:id' do
  classroom = Classroom.find_by_id(params['id'])
  if classroom
    begin
      attributes = JSON.parse(request.body.read)
      updated_classroom = classroom.update_attributes(attributes)
      if updated_classroom
        classroom.to_json
      else
        error 400, classroom.errors.to_json
      end
    rescue => e
      error 400, {:error => e.message}.to_json
    end
  else
    error 404, {:error => 'classroom not found'}.to_json
  end
end

# delete a classroom
delete '/classrooms/:id' do
  classroom = Classroom.find_by_id(params[:id])
  if classroom
    classroom.destroy
    classroom.to_json
  else
    error 404, {:error => 'classroom not found'}.to_json
  end
end




#
# HELPERS
#

def show_request(request,log)
  log.debug "request.request_method: #{request.request_method}"
  log.debug "request.body: #{request.body}"
  log.debug "request.cookies: #{request.cookies}"
  log.debug "request.env: #{request.env}"
  log.debug "request.content_length: #{request.content_length}"
  log.debug "request.media_type: #{request.media_type}"
end

get '/foo' do
  show_request(request, log)
end