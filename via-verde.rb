require 'sinatra'
require 'csv'
require 'json'

strips = CSV.read("strips-assetbar.tsv", { :col_sep => "\t", :liberal_parsing => true})

get '/' do
  erb :index
end

get '/strips' do
  erb :strips, :locals => {:strips => strips}
end

get '/about' do
  erb :about
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

get '/timeline' do
  erb :timeline
end
