#!/usr/bin/env ruby

require 'dotenv/load'
require 'httparty'
require_relative './lib/bot'

bot = Bot.new ENV['REDIS_URL']
tweet_url = "https://maker.ifttt.com/trigger/tweet_generated/with/key/#{ENV['IFTTT_KEY']}"

HTTParty.post(tweet_url, body: { value1: bot.speak })
