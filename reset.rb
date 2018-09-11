#!/usr/bin/env ruby

require 'dotenv/load'
require_relative './lib/bot.rb'

bot = Bot.new ENV['REDIS_URL']

bot.reset
