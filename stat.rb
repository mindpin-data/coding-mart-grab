require 'rubygems'

require 'bundler/setup' 
Bundler.require

require 'net/http'

require_relative './lib/mart-page'
require_relative './lib/mart-page-parser'
require_relative './lib/stat'

Mongoid.load!("mongoid.yml", :development)

CodingMart::Stat.save_statuses
CodingMart::Stat.save_types