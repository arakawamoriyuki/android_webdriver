# coding: utf-8

module AndroidWebDriver
  module CustomWebDriver
    # driver.quit時に実行される処理を登録する
    def add_quit_action(callable)
      @quit_actions = [] if @quit_actions.nil?
      @quit_actions.push callable
    end

    # driver.quitのoverride。終了後に登録したquit_actionsを実行する
    def quit
      super
      @quit_actions.each do |quit_action|
        quit_action.call()
      end
    end
  end
end
