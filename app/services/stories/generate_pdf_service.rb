module Stories
  class GeneratePdfService < ApplicationService
    def initialize(story:, download_dir_path:)
      @story = story
      @pdf_file_path = File.join(download_dir_path, "#{story.title.parameterize}.pdf")
    end

    def call
      body = ApplicationController.render(
        template: 'pdf/story',
        layout: 'pdf',
        assigns: { story: story }
      )
      footer = ApplicationController.render(
        template: 'pdf/footer',
        layout: 'pdf'
      )
      pdf_data = WickedPdf.new.pdf_from_string(
        body,
        footer: { content: footer },
        zoom: 1.5,
        margin: {
          top: 15,
          bottom: 15,
          left: 10,
          right: 10
        }
      )
      File.open(pdf_file_path, 'wb') { |file| file << pdf_data }
    end

    private

    attr_reader :story, :pdf_file_path
  end
end
