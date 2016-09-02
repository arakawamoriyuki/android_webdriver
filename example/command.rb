require 'android_webdriver'
require 'optparse'

# $ ruby command.rb -h
# $ ruby command.rb {udid}
# $ ruby command.rb {udid} --port 4444 --bootstrap-port 4445 --selendroid-port 4446 --chromedriver-port 4447

opts = {}
args = []
OptionParser.new do |option_parser|
  option_parser.on('--browser-name VALUE', "Name of the mobile browser: Chrome or Browser or Selendroid"){|v| opts[:browserName] = v}
  option_parser.on('--selendroid-path VALUE', "path of selendroid-standalone.jar"){|v| opts[:selendroidPath] = v}

  option_parser.on('-p VALUE', '--port VALUE', 'port to listen on'){|v| opts[:port] = v}
  option_parser.on('--bootstrap-port VALUE', 'port to use on device to talk to Appium'){|v| opts[:bootstrapPort] = v}
  option_parser.on('--selendroid-port VALUE', 'Local port used for communication with Selendroid'){|v| opts[:selendroidPort] = v}
  option_parser.on('--chromedriver-port VALUE', 'Port upon which ChromeDriver will run'){|v| opts[:chromedriverPort] = v}
  option_parser.banner += ' UDID'
  args = option_parser.parse!(ARGV)
end

puts "Usage: ruby #{__FILE__} <UDID> [:<options>]" or exit if args[0].nil?

@driver = AndroidWebDriver.for(args[0], opts)

@wait = Selenium::WebDriver::Wait.new(:timeout => 10)
@driver.navigate.to 'https://www.google.co.jp'
@wait.until { @driver.find_element(css: "#lst-ib") }.send_keys("search")
sleep 5
@driver.quit