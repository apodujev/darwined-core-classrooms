require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/reloader' if development?
require'./environments'
require './models/post'

# the HTTP entry points to our service

# set content type for all requests
before do
  content_type 'application/json'
end

# get all posts
get '/api/v1/posts' do
  Post.all.to_json
end

# get a post by id
get '/api/v1/posts/:id' do
  post = Post.find_by_id(params[:id])
  if post
    post.to_json
  else
    error 404, {:error => "post not found"}.to_json
  end
end

# create a post
post '/api/v1/posts' do
  begin
    post = Post.create(JSON.parse(request.body.read))
    if post.valid?
      post.to_json
    else
      error 400, post.errors.to_json # :bad_request
    end
  rescue => e
    error 400, {:error => e.message}.to_json
  end
end

# update a post
put '/api/v1/posts/:id' do
  post = Post.find_by_id(params['id'])
  if post
    begin
      attributes = JSON.parse(request.body.read)
      updated_post = post.update_attributes(attributes)
      if updated_post
        post.to_json
      else
        error 400, post.errors.to_json
      end
    rescue => e
      error 400, {:error => e.message}.to_json
    end
  else
    error 404, {:error => 'post not found'}.to_json
  end
end

# delete a post
delete '/api/v1/posts/:id' do
  post = Post.find_by_id(params[:id])
  if post
    post.destroy
    post.to_json
  else
    error 404, {:error => 'post not found'}.to_json
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