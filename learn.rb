#!/usr/bin/env ruby

require 'dotenv/load'
require 'sinatra'
require_relative './lib/bot'

bot = Bot.new ENV['REDIS_URL']

post "/#{ENV['IFTTT_ENDPOINT']}" do
  bot.learn(request.body)
end
