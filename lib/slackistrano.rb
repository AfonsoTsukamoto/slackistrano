require 'slackistrano/version'
require 'net/http'
require 'json'

load File.expand_path("../slackistrano/tasks/slack.rake", __FILE__)

module Slackistrano
  def self.post(options = {})
    payload = options.delete(:payload)
    if options[:via_slackbot]
      uri = URI(URI.encode("https://#{options[:team]}.slack.com/services/hooks/slackbot?token=#{options[:token]}&channel=#{payload[:channel]}"))

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        response = http.request_post uri.request_uri, payload[:text]
      end
    else
      uri = URI.parse("https://#{options[:team]}.slack.com/services/hooks/incoming-webhook")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data('token' => options[:token], 'payload' => payload.to_json)

      res = http.request(request)
    end
  rescue => e
    puts "There was an error notifying Slack."
    puts e.inspect
  end
end