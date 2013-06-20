#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'yaml'
require 'ostruct'
require 'twitter'
require 'tweetstream'

CONFIG_FILEPATH = File.join(File.dirname(__FILE__), 'config.yml')

def config
  @conf ||= OpenStruct.new(YAML.load_file(CONFIG_FILEPATH))
end

TweetStream.configure do |c|
  c.consumer_key       = config.consumer_key
  c.consumer_secret    = config.consumer_secret
  c.oauth_token        = config.oauth_token
  c.oauth_token_secret = config.oauth_token_secret
end

Twitter.configure do |c|
  c.consumer_key       = config.consumer_key
  c.consumer_secret    = config.consumer_secret
  c.oauth_token        = config.oauth_token
  c.oauth_token_secret = config.oauth_token_secret
end

daemon = TweetStream::Daemon.new('hagonchu', log_output: true)

daemon.track(config.terms) do |status|
  case status.text
  when /(?:\p{Hiragana}|\p{Katakana}|[一-龠々])/
    # Retweet japanese only
    Twitter.retweet(status.id)
    Twitter.follow(status.user.id)
  end
end
