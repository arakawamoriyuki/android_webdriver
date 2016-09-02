module AndroidWebDriver
  module MultiDevices

    # 逐次処理で実行
    def self.sequential(udids, caps = {})
      udids.each do |udid|
        driver = AndroidWebDriver.for(udid, caps)
        yield driver
      end
    end

    # マルチプロセスで実行
    def self.parallel(udids, caps = {}, in_processes: 4)
      # 全端末分ポートを確保
      ports = AndroidWebDriver::Utils.get_ports(udids.count * 4)
      # ポートを各端末に割り当てる
      devices = udids.map do |udid|
        device = {
          udid: udid,
          caps: {
            port: ports.shift,
            bootstrapPort: ports.shift,
            selendroidPort: ports.shift,
            chromedriverPort: ports.shift,
          }
        }
      end
      # マルチプロセスで実行
      Parallel.each(devices, in_processes: in_processes) do |device|
        driver = AndroidWebDriver.for(device[:udid], device[:caps])
        yield driver
      end
    end
  end
end