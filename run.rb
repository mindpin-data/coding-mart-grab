require 'rubygems'

require 'bundler/setup' 
Bundler.require

require 'net/http'

require_relative './lib/grabber'
require_relative './lib/mart-page'

Mongoid.load!("mongoid.yml", :development)

def grab(id)
  grab_once(id)
  if id < 6000
    grab id + 1
  end
end

def grab_once(id)
  g = CodingMart::Grabber.new(id)
  g.save
end

grab(4000)
# grab_once(5471)