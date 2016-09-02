# coding: utf-8

require 'android_webdriver'
require 'thor'

# bundle exec android_webdriver doctor

module AndroidWebDriver
  class CLI < Thor

    desc "android webdriver environment check", "bundle exec android_webdriver doctor"
    def doctor

      commands = ['java', 'adb', 'appium']
      environments = ['$JAVA_HOME', '$ANDROID_HOME']
      files = ['selendroid-standalone-*.*.*-with-dependencies.jar']

      commands.each do |command|
        bool = AndroidWebDriver::Utils.command_exists?(command)
        color = bool ? :green : :red
        word = bool ? 'exists' : 'command not found'
        say("#{command} #{word}", color)
      end

      environments.each do |environment|
        bool = AndroidWebDriver::Utils.environment_exists?(environment)
        color = bool ? :green : :red
        word = bool ? 'is set' : 'is not set'
        say("#{environment} #{word}", color)
      end

      files.each do |file|
        bool = AndroidWebDriver::Utils.file_exists?('selendroid-standalone-*.*.*-with-dependencies.jar')
        color = bool ? :green : :red
        word = bool ? 'is set' : 'is not set'
        say("#{file} #{word}", color)
      end
    end

    desc "android webdriver process kill", "appium & selendroid & chromedriver process kill"
    def kill
      `ps ax | grep appium | awk '{print $1}' | xargs kill || ps ax | grep selendroid | awk '{print $1}' | xargs kill || ps ax | grep chromedriver | awk '{print $1}' | xargs kill`
    end
  end
end
