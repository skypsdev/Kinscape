class SanitizerService
  class << self
    def call(string)
      sanitized = Sanitize.fragment(string)
      CGI.unescapeHTML(sanitized.strip.gsub(/&nbsp;/i, ''))
    end
  end
end
