require 'sinatra'
require 'csv'
require 'json'
require 'rss'

strips = CSV.read("strips-assetbar.tsv", { :col_sep => "\t", :liberal_parsing => true})

blogs = JSON.load open("blogs.json")
feeds = blogs.map {|k, v|
  RSS::Parser.parse(open("http://#{v}.blogspot.com/feeds/posts/default?max-results=999"))
}

dates = feeds.map {|feed| feed.items.map { |item| item.updated.content }}.flatten
height = 20000

keydates = (1..182).map { |n| dates.min.to_date >> n }.take_while { |date| date < dates.max.to_date }
keydates.each do |date|
  p (date.to_time - dates.min)/(dates.max - dates.min)
end

get '/' do
  erb :index
end

get '/strips/' do
  erb :strips, :locals => {:strips => strips}
end

get '/blogs/' do
  erb :blogs, :locals => {:feeds => feeds,
                          :mindate => dates.min, :maxdate => dates.max,
                          :height => height,
                          :keydates => keydates
  }
end

get '/assetbar/*/' do
  asset_id = params[:splat][0]
  comments = JSON.load(File.open("comments/#{asset_id}.json"))
  p asset_id
  strip = strips.select { |m, d, y, t, a| a.to_s == asset_id }
  if strip
    erb :assetbar, :locals => {:comments => comments, :strip => strip[0] }
  end
end

get '/timeline/' do
  erb :timeline, :locals => {:strips => strips,
                             :feeds => feeds
  }
end
