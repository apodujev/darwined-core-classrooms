require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/reloader' if development?
require'./environments'
require './models/room'

# the HTTP entry points to our service

# set content type for all requests
before do
  content_type 'application/json'
end

# get all rooms
get '/api/v1/rooms' do
  Room.all.to_json
end

# get a room by id
get '/api/v1/rooms/:id' do
  room = Room.find_by_id(params[:id])
  if room
    room.to_json
  else
    error 404, {:error => "room not found"}.to_json
  end
end

# create a room
post '/api/v1/rooms' do
  begin
    room = Room.create(JSON.parse(request.body.read))
    if room.valid?
      room.to_json
    else
      error 400, room.errors.to_json # :bad_request
    end
  rescue => e
    error 400, {:error => e.message}.to_json
  end
end

# update a room
put '/api/v1/rooms/:id' do
  room = Room.find_by_id(params['id'])
  if room
    begin
      attributes = JSON.parse(request.body.read)
      updated_room = room.update_attributes(attributes)
      if updated_room
        room.to_json
      else
        error 400, room.errors.to_json
      end
    rescue => e
      error 400, {:error => e.message}.to_json
    end
  else
    error 404, {:error => 'room not found'}.to_json
  end
end

# delete a room
delete '/api/v1/rooms/:id' do
  room = Room.find_by_id(params[:id])
  if room
    room.destroy
    room.to_json
  else
    error 404, {:error => 'room not found'}.to_json
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