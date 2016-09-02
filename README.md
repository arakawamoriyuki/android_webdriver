# Not yet been published in the rubygems.

Please to build manually.

# AndroidWebDriver

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/android_webdriver`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'android_webdriver'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install android_webdriver

## Usage

### command line tool

#### environment check

    $ bundle exec android_webdriver doctor

### single device

#### sample

    require 'android_webdriver'
    # Confirmed in command of `adb devices`
    udid = '{android device udid}'
    driver = AndroidWebDriver.for(udid)
    driver.navigate.to 'https://www.google.co.jp'
    driver.quit

#### option sample

    require 'android_webdriver'
    # Confirmed in command of `adb devices`
    udid = '{android device udid}'
    driver = AndroidWebDriver.for(udid, {

      ## automation browser name. (Chrome or Browser or Selendroid)
      # default is auto select.
      browserName: 'Chrome'

      ## path of selendroid-standalone.jar.
      # default is auto select. (find from the execution directory)
      # `find . -name 'selendroid-standalone-*.*.*-with-dependencies.jar' -type f`
      selendroidPath: './selendroid-standalone-*.*.*-with-dependencies.jar'

      ## port to listen on.
      # default is auto select. (find from the empty port)
      port: '4444'

      ## port to use on device to talk to Appium.
      # default is auto select. (find from the empty port)
      bootstrapPort: '4445'

      ## Local port used for communication with Selendroid.
      # default is auto select. (find from the empty port)
      selendroidPort: '4446'

      ## Port upon which ChromeDriver will run.
      # default is auto select. (find from the empty port)
      chromedriverPort: '4447'

      ## output destination of the log.
      # default is '/dev/null 2>&1'
      logPath: "./log/#{Time.now.strftime('%Y%m%d%H%M%S')}.#{udid}.log"
    })
    driver.navigate.to 'https://www.google.co.jp'
    driver.quit

### multiple devices

#### sequential processing sample

    require 'android_webdriver'
    # Confirmed in command of `adb devices`
    udids = ['{android device udid}',...]
    AndroidWebDriver::MultiDevices.sequential(udids) do |driver|
      driver.navigate.to 'https://www.google.co.jp'
      driver.quit
    end

#### parallel processing sample

    require 'android_webdriver'
    # Confirmed in command of `adb devices`
    udids = ['{android device udid}',...]
    AndroidWebDriver::MultiDevices.parallel(udids) do |driver|
      driver.navigate.to 'https://www.google.co.jp'
      driver.quit
    end

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/android_webdriver. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

