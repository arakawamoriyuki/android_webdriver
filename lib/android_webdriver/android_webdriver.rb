module AndroidWebDriver
  def self.for(udid, caps = {})
    @udid = udid
    @caps = caps

    # connectできていない場合の為5回再施行
    5.times.each do |i|
      # adb connect
      puts "executing cmd -> adb connect #{@udid}"
      `adb connect #{@udid}`
      sleep 5
      # version判定
      puts "executing cmd -> adb -s #{@udid} shell getprop ro.build.version.release"
      version = `adb -s #{@udid} shell getprop ro.build.version.release`
      versions = version.split('.')
      @majorVersion = versions[0].to_i
      @minorVersion = versions[1].to_i
      puts "android version #{@majorVersion}.#{@minorVersion}"
      break if @majorVersion != 0
      puts "continue"
    end

    ## 使用ブラウザの選択
    # optionsで指定がある場合
    if !@caps[:browserName].nil?
      @caps[:browserName] = @caps[:browserName].capitalize
      case @caps[:browserName]
      when 'Chrome'
        raise "Cannot use Chrome. Android version must be >= 4.2" unless 4 < @majorVersion or (4 == @majorVersion and 4 <= @minorVersion)
        raise "Cannot use Chrome. Chrome is not installed on android" unless AndroidWebDriver::Utils.package_exists(@udid, 'com.android.chrome')
        raise "Cannot use Chrome. Chrome version must be >= 43.0.2357.0" unless 43 < AndroidWebDriver::Utils.package_version(@udid, 'com.android.chrome')
      when 'Browser'
        raise "Cannot use Browser. Android version must be >= 4.4" unless 4 < @majorVersion or (4 == @majorVersion and 2 <= @minorVersion)
        raise "Cannot use Browser. Browser is not installed on android" unless AndroidWebDriver::Utils.package_exists(@udid, 'com.android.browser')
      when 'Selendroid'
        raise "Cannot use Selendroid. Android version must be >= 2.3" unless 2 < @majorVersion or (2 == @majorVersion and 3 <= @minorVersion)
      else
        raise "Cannot use '#{@caps[:browserName]}'. please use 'Chrome' or 'Browser' or 'Selendroid'"
      end
    # 指定なしの場合
    else
      # 4.2以上でchrome v43以上がinstallされていればChrome
      if (4 < @majorVersion or (4 == @majorVersion and 2 <= @minorVersion)) and
          AndroidWebDriver::Utils.package_exists(@udid, 'com.android.chrome') and 43 < AndroidWebDriver::Utils.package_version(@udid, 'com.android.chrome')
        @caps[:browserName] = 'Chrome'
      # 4.4以上でbrowserがinstallされていればBrowser
      elsif (4 < @majorVersion or (4 == @majorVersion and 4 <= @minorVersion)) and
          AndroidWebDriver::Utils.package_exists(@udid, 'com.android.browser')
        @caps[:browserName] = 'Browser'
      # 2.3以上ならSelendroid
      elsif (2 < @majorVersion or (2 == @majorVersion and 3 <= @minorVersion))
        @caps[:browserName] = 'Selendroid'
      else
        raise "Android version must be >= 2.3"
      end
    end
    puts "target browser #{@caps[:browserName]}"

    ## デフォルト設定
    # ポート類の設定
    ports = AndroidWebDriver::Utils.get_ports(4)
    @caps[:port] = ports.shift if @caps[:port].nil?
    @caps[:bootstrapPort] = ports.shift if @caps[:bootstrapPort].nil?
    @caps[:selendroidPort] = ports.shift if @caps[:selendroidPort].nil?
    @caps[:chromedriverPort] = ports.shift if @caps[:chromedriverPort].nil?
    # selendroid-standaloneの場所を探す
    if @caps[:selendroidPath].nil?
      findSelendroidPaths = AndroidWebDriver::Utils.get_file_path 'selendroid-standalone-*.*.*-with-dependencies.jar'
      raise "selendroidPath parameter not set" unless findSelendroidPaths.count
      @caps[:selendroidPath] = findSelendroidPaths.first
    end
    @caps[:logPath] = '/dev/null 2>&1' if @caps[:logPath].nil?

    ## 自動化ツールの選択
    # Chrome,Browserの場合はAppium
    if ['Chrome', 'Browser'].include?(@caps[:browserName])
      # Appiumの実行関数
      automation_run = -> {
        options = [
          '--session-override',
          "-p #{@caps[:port]}",
          "-bp #{@caps[:bootstrapPort]}",
          "--selendroid-port #{@caps[:selendroidPort]}",
          "-U #{@udid}"
        ]
        options.push "--chromedriver-port #{@caps[:chromedriverPort]}" if @caps[:browserName] == 'Chrome'

        executing_cmd = "appium #{options.join(' ')}"
        puts "executing cmd -> #{executing_cmd} > #{@caps[:logPath]} &"
        system("#{executing_cmd} > #{@caps[:logPath]} &")

        # 確実に実行されるまで5回待機
        5.times.each do |i|
          sleep 5
          break unless AndroidWebDriver::Utils.process_empty?(@caps[:port])
        end

        # 戻り値として終了コマンドを実行する関数を返却
        automation_quit_action = -> {
          automation_quit_cmd = "ps ax | grep '#{executing_cmd}' | awk '{print $1}' | xargs kill"
          puts "executing cmd -> #{automation_quit_cmd}"
          `#{automation_quit_cmd}`
        }
      }

      # Driverの作成関数
      create_driver = -> {
        puts "create appium driver"
        Appium::Driver.new({
          caps: {
            "appium-version"  => "1.0",
            platformName:     'Android',
            platformVersion:  "#{@majorVersion}.#{@minorVersion}",
            deviceName:       'Android',
            automationName:   (4 < @majorVersion or (4 == @majorVersion and 4 <= @minorVersion)) ? 'Appium' : 'Selendroid',
            browserName:      @caps[:browserName],
            unicodeKeyboard:  true,
          },
          appium_lib: {
            wait:             10,
            server_url:       "http://127.0.0.1:#{@caps[:port]}/wd/hub",
          },
        }).start_driver
      }
    # その他の場合はSelendroid
    else
      # selendroid-standaloneの実行関数
      automation_run = -> {
        java_home = `echo $JAVA_HOME`.strip
        executing_cmd = "#{java_home}/bin/java -jar #{@caps[:selendroidPath]} -port #{@caps[:port]}"
        puts "executing cmd -> #{executing_cmd} > #{@caps[:logPath]} &"
        system("#{executing_cmd} > #{@caps[:logPath]} &")

        # 確実に実行されるまで5回待機
        5.times.each do |i|
          sleep 5
          break unless AndroidWebDriver::Utils.process_empty?(@caps[:port])
        end

        # 戻り値として終了コマンドを実行する関数を返却
        automation_quit_action = -> {
          automation_quit_cmd = "ps ax | grep '#{executing_cmd}' | awk '{print $1}' | xargs kill"
          puts "executing cmd -> #{automation_quit_cmd}"
          `#{automation_quit_cmd}`
        }
      }

      # Driverの作成関数
      create_driver = -> {
        puts "create selendroid driver"
        Selenium::WebDriver.for(
          :remote,
          :url => "http://127.0.0.1:#{@caps[:port]}/wd/hub",
          :desired_capabilities => :android
        )
      }
    end

    # automationツールの実行
    autonmation_quit_action = automation_run.call()

    # ツールの停止とadb connectの解除を行う関数
    quit_actions = [autonmation_quit_action, ->{
      cmd = "adb disconnect #{@udid}"
      puts "executing cmd -> #{cmd}"
      `#{cmd}`
    }]

    begin
      # driverの作成
      @driver = create_driver.call()
      @driver.extend AndroidWebDriver::CustomWebDriver
      # 終了時にアクションを登録
      quit_actions.each do |quit_action|
        @driver.add_quit_action quit_action
      end
    rescue => e
      p e.message
      # エラー時にも確実にプロセスキルを行う
      quit_actions.each do |quit_action|
        quit_action.call()
      end
    end

    # driver返却
    return @driver
  end
end