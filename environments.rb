configure :development do
  set :database, 'sqlite:///db/development.sqlite3.db'  
end

configure :test do
  set :database, 'sqlite:///db/test.sqlite3.db'  
end

configure :production do
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres:///locahost/mydb')

  ActiveRecord::Base.establish_connection(
    :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host     => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8'
  )
end