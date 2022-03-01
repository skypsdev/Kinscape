module Stories
  class GeneratePdfService < ApplicationService
    def initialize(story:, download_dir_path:)
      @story = story
      @pdf_file_path = File.join(download_dir_path, "#{story.title.parameterize}.pdf")
    end

    def call
      rendered_string = ApplicationController.render(
        template: 'pdf/story',
        layout: 'pdf',
        assigns: { story: story }
      )
      pdf_data = WickedPdf.new.pdf_from_string(rendered_string)
      File.open(pdf_file_path, 'wb') { |file| file << pdf_data }
    end

    private

    attr_reader :story, :pdf_file_path
  end
end
