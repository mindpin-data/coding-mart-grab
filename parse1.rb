require 'rubygems'

require 'bundler/setup' 
Bundler.require

require 'net/http'

require_relative './lib/mart-page'
require_relative './lib/mart-page-parser'

Mongoid.load!("mongoid.yml", :development)

# 第一次清洗
cm = CodingMart::MartPageParser1.new 10
ap cm.parse[:brief]
# CodingMart::MartPageParser1.parse_all
