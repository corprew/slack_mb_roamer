# slack_mb_roamer installation & configuration.

_AKA The "Where is Corprew drinking Coffee Daemon"_ 

This gem executable was something I created a while ago to help people that I was working with remotely figure out where I was working from on any particular day.  I removed some of the weirder features and figured I would share it here as a service to others. This runs a gem's executable when the network configuration changes on an MacOS computer using `launchctl`.

You install the gem by typing `gem install slack_mb_roamer`.  If you use rvm, you should use `rvm wrapper` to generate a wrapper for this executable, otherwise it won't work because the path will be broken and you'll see the errors in your system console after you install the service

This takes information from a file `.slack_roamer.yaml` in your home directory and changes your status and/or posts messages to slack depending on whether or not there is a match between one of the wifi network's SSIDs and your network.  You need to generate a slack app to use this.  You need to authenticate it against OAUTH with the following permissions: `chat:write:bot`, `users:write`, `users.profile:read`, and `users.profile:write`.



example config file
```
bot_token:  xoxp-long-hex-string-of-digits

post: true
status: true
channel: "#general"

default_location: ""
default_emoji: ""

wifis:
  -
    name: "MyHomeWifi"
    location: "is somewhere near home"
    emoji: ":sunglasses:"
  -
    name: "Ballard Coffee Works"
    location: "in Ballard"
    emoji: ":point_left:"
  -
    name: "xfinitywifi"
    location: "at somewhere comcast serves"
```

`default_location` and `default_emoji` are empty strings by default, which means that if you are at an unrecognized wifi network, it won't post.  

`post` will cause it to post to the channel specified in `channel` if it exists, should be 'true' or 'false'
`status` will cause it to update your status when the network changes, should be 'true' or 'false'

The `wifis` collection is the list of wifi networks that it matches.  

## Running

You should get the config file working a couple of times running it manually as `slack_mb_roamer` before you turn this into a service.

## installing with LaunchD.

first, figure out what the path to the executable is with `which slack_mb_roamer`.

* if that path includes 'rvm', you must use rvm wrapper to generate a wrapper and use the path to the wrapper instead.  For example, I have `/Users/corprew/.rvm/gems/ruby-2.5.3/wrappers/slack_mb_roamer` in the file, but my path to the program is `/Users/corprew/.rvm/gems/ruby-2.5.3/bin/slack_mb_roamer`.

Second, go to your `~/Library/LaunchAgents` directory and create a file named `org.corprew.slack_mb_roamer.plist` and put the following contents in it:

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" \
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>org.corprew.slack_mb_roamer</string>
  <key>LowPriorityIO</key>
  <true/>
  <key>ProgramArguments</key>
  <array>
    <string>YOUR PATH TO THE SLACK_MB_ROAMER EXECUTABLE HERE</string>
  </array>

  <key>WatchPaths</key>
  <array>
    <string>/etc/resolv.conf</string>
    <string>/Library/Preferences/SystemConfiguration/NetworkInterfaces.plist</string>
    <string>/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist</string>
  </array>

  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
```

This file says
* I have an program that I would like to run occasionally.
* It exists in a particular place in the system.
* Run it when these files change, at a low priority.

You can name the service something else, but you have to be consistent.  At this point, load and run the service:

`launchctl load org.corprew.slack_mb_roamer.plist`

`launchctl start org.corprew.slack_mb_roamer`

...and then you should be good to go.

Let me know if you run into any issues, but please be mindful of the [LICENSE](LICENSE.txt).
