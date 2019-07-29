require "slack_mb_roamer/version"
require "yaml"
require "slack_ruby_client"

module SlackMbRoamer
  class Error < StandardError; end

  AIRPORT_COMMAND = "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I"
  # Your code goes here...

  stdout, stderr, status = Open3.capture3(AIRPORT_COMMAND)

  unless "0" == status.to_s.split(" ").last
    puts "exit status #{status}"
    raise stderr
  end
  SSID_line = stdout.lines.select { |x| x.include? " SSID" }.first
  if SSID_line.nil? or SSID_line.empty?
    raise "no SSID found"
  end
  #
  #  Probably some maniac somewhere has colons in their SSID name.
  #
  SSID = SSID_line.split(":").slice(1..-1).join(":").strip
  #
  #
  #
  prefs = begin
            YAML.load(File.read(File.expand_path("~/.slack_roamer.yaml")))
          rescue
            raise "config file couldn't be loaded"
          end
  location = prefs["default_location"] || "at some place unspecified"
  emoji = prefs["default_emoji"]

  networks = prefs["wifis"]

  current_network = networks.select { |network| network["name"] == SSID }.first

  unless current_network.nil?
    unless current_network["location"].nil? || current_network["location"].empty?
      location = current_network["location"]
      emoji = current_network["emoji"]
    end
  end

  unless location.nil? || location.empty?
    client = client = Slack::Web::Client.new
    client.token = prefs["bot_token"]
    client.auth_test
    profile = client.users_profile_get.profile
    if prefs["post"]
      client.chat_postMessage(channel: prefs["channel"], text: "@#{profile.real_name} is #{location}")
    end
    if prefs["status"]
      client.users_profile_set(profile: { status_text: "currently #{location}", status_emoji: emoji }.to_json)
    end
  else
    puts "empty location, not posting to slack."
  end
end
