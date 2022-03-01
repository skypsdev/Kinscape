Capybara.register_driver :selenium_chrome_headless_no_sandbox do |app|
  Capybara::Selenium::Driver.load_selenium
  browser_options = ::Selenium::WebDriver::Chrome::Options.new
  browser_options.args << '--headless'
  browser_options.args << '--disable-gpu'
  # Sandbox cannot be used inside unprivileged Docker container
  browser_options.args << '--no-sandbox'
  # TODO! workaround for 'bug' introduced in Chrome 74
  # https://github.com/teamcapybara/capybara/issues/2181#issuecomment-490601079
  browser_options.args << '--enable-features=NetworkService,'\
                          'NetworkServiceInProcess'
  Capybara::Selenium::Driver.new(app, browser: :chrome,
                                      options: browser_options)
end

def resize_window(width, height)
  case Capybara.current_driver
  when :selenium, :chrome, :selenium_chrome,
       :selenium_chrome_headless, :webkit, :selenium_chrome_headless_no_sandbox
    Capybara.current_session.current_window.resize_to(width, height)
  else
    raise NotImplementedError,
          "resize_window is not supported by #{Capybara.current_driver}"
  end
end

RSpec.configure do |config|
  config.before do |example|
    Capybara.reset_sessions!

    if example.metadata[:js]
      case example.metadata[:screen]
      when :small  then resize_window(540, 480)
      when :medium then resize_window(760, 640)
      when :large  then resize_window(960, 640)
      else resize_window(1280, 768)
      end
    end

    example.metadata[:driver] == :selenium && switch_to_window(current_window)
  end
end

# Capybara.javascript_driver = :selenium # use firefox
Capybara.javascript_driver = :selenium_chrome # use_chrome
# use headless chrome unless
unless ENV['HEAD']
  Capybara.javascript_driver = :selenium_chrome_headless_no_sandbox
end
Capybara.server = :puma, { Silent: true } unless ENV['VERBOSE']

Capybara.configure do |config|
  config.default_max_wait_time = 5
end
