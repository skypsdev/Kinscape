module Features
  def stub_zencoder
    stub_request(:post, 'https://app.zencoder.com/api/v2/jobs')
  end

  def expect_saved_status
    expect(page).to have_css('.saving-status', text: 'Saved')
  end

  def flash
    find('flash-message')
  end

  def show_screenshot
    if RSpec.current_example.metadata[:js]
      name = Time.zone.now.strftime('%Y-%m-%d-%H-%M-%S-%L')
      path = Rails.root.join(Capybara.save_and_open_page_path, "#{name}.png")
      save_screenshot(path)
      Launchy.open(path.to_s)
    else
      message = 'show_screenshot can only be used in JavaScript feature specs'
      raise ArgumentError, message
    end
  end
end
