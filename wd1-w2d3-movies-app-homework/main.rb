require 'pry'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'httparty'
require 'json'
require 'pg'


get '/movies/?:year?' do            # optional parameters!!!!! -> ?
 db = PG.connect(dbname: 'movies_database', host: 'localhost')
 begin
  if params[:year]
    sql = "select poster from movies where year = '#{params[:year]}'"
  else
    sql = "select poster from movies"
  end
  @results = db.exec(sql)

ensure
  db.close
end

erb :posters
end


get '/' do
  if params[:title]
    db = PG.connect(dbname: 'movies_database', host: 'localhost')
    begin

    name = params[:title].gsub(' ', '+')  #subsitutes spaces for +
    url = "http://www.omdbapi.com/?t=#{name}"
    html = HTTParty.get(url)
    @hash = JSON(html)

    sql = "select count(*) as record_count from movies where title = '#{@hash['Title']}'"

    film_exists_in_db = db.exec(sql).first['record_count'].to_i  > 0

    unless film_exists_in_db
      sql = "insert into movies (title, year, rated, released, runtime, genre, director, writers, actors, plot, poster) values ('#{@hash['Title']}', '#{@hash['Year']}', '#{@hash['Rated']}', '#{@hash['Released']}', '#{@hash['Runtime']}', '#{@hash['Genre']}', '#{@hash['Director']}', '#{@hash['Writer']}', '#{@hash['Actors']}', '#{@hash['Plot']}', '#{@hash['Poster']}')"

      db.exec(sql)
    end
  ensure
    db.close
  end
end

erb :movie
end
