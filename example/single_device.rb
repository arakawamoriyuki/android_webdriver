require 'android_webdriver'

udid = 'xxxxxxxxxx'

driver = AndroidWebDriver.for(udid)
driver.navigate.to 'https://www.google.co.jp'
driver.quit
