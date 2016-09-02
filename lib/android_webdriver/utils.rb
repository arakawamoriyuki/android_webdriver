# coding: utf-8

module AndroidWebDriver
  class Utils

    # ファイルパスを配列で取得
    def self.get_file_path(file, dir = '.')
      `find #{dir} -name '#{file}' -type f`.split
    end

    # ファイルが存在するか
    def self.file_exists?(file, dir = '.')
      paths = get_file_path(file, dir)
      paths.count != 0
    end

    # コマンドが存在するか
    def self.command_exists?(command)
      `if type #{command} &> /dev/null; then
        echo '0'
      else
        echo '1'
      fi`.include? '0'
    end

    # 環境変数が存在するか
    def self.environment_exists?(environment)
      `if [ "#{environment}" != "" ]; then
        echo '0'
      else
        echo '1'
      fi`.include? '0'
    end

    # 使用可能なポートの取得
    def self.get_ports(count = 1, current_port = 40000)
      ports = []
      while ports.count < count
        while current_port < 65536
          current_port += 1
          next if ports.include?(current_port)
          break if process_empty?(current_port)
        end
        ports.push current_port
      end
      ports
    end

    # ポートが使用中か判定
    def self.process_empty?(port)
      `netstat -an | grep #{port}`.empty?
    end

    # パッケージがインストールされているか調べる
    def self.package_exists(udid, package)
      puts "executing cmd -> adb -s #{udid} shell pm list packages | grep #{package}"
      result = `adb -s #{udid} shell pm list packages | grep #{package}`
      result.split.include? "package:#{package}"
    end

    # パッケージのバージョンを調べる
    def self.package_version(udid, package)
      puts "executing cmd -> adb -s #{udid} shell dumpsys package #{package} | grep versionName"
      result = `adb -s #{udid} shell dumpsys package #{package} | grep versionName`
      versions = result.split.map do |line|
        matchs = line.match(/versionName=([\d]+)/)
        matchs[1].to_i
      end
      versions.max
    end
  end
end
