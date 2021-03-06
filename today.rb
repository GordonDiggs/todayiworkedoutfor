require 'rubygems'
require 'sinatra'
require 'sinatra/sequel'
require 'sqlite3'
require 'haml'
require 'sass'
require 'chronic'

set :database, 'sqlite://today.db'

migration "create workouts table" do
  database.create_table :workouts do
    primary_key :id
    text        :type
    integer     :duration, :default => 45
    double      :calories_burned
    double      :weight
    timestamp   :date, :null => false
  end
end

get '/' do
  haml :index
end

post '/create_workout' do
  puts "#{params.inspect} #{Chronic.parse(params[:workout][:date])}"
  params[:workout]['date'] = Chronic.parse(params[:workout][:date])
  puts "#{params.inspect}"
  Workout.create(params[:workout])
  redirect '/'
end

class Workout < Sequel::Model
  def before_create
    self.date ||= Time.now
    super
  end

  def describe
    "On <b>#{self.date.strftime("%A, %B %d, %Y")}</b> I worked out for <b>#{self.duration}</b> minutes doing the <b>#{self.type}</b>. I burned <b>#{self.calories_burned}</b> calories and weighed <b>#{self.weight}</b> pounds."
  end
end
