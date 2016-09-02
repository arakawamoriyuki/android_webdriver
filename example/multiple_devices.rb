require 'android_webdriver'

# TODO:
# androidデバイス側でgoogleログイン必要
# parallelではSelendroidは1台しか動かない？
# parallelではSelendroidが混ざると他も不安定

devices = [
  'xxxxxxxxxxxxxx',
  'xxxxxxxxxxxxxx',
  'xxxxxxxxxxxxxx',
  'xxxxxxxxxxxxxx',
]


# AndroidWebDriver::MultiDevices.sequential(devices) do |driver|
AndroidWebDriver::MultiDevices.parallel(devices) do |driver|
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  driver.navigate.to 'https://www.google.co.jp'
  wait.until { driver.find_element(css: "#lst-ib") }.send_keys("search")
  sleep 5
  driver.quit
end
