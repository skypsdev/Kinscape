module Publications
  class DownloadsController < ApplicationController
    def show
      authorize! :read, publication
      send_file(
        ::Stories::GenerateZipService.call(publication.story),
        type: 'application/zip',
        filename: "story-##{publication.story.id}-files.zip"
      )
    end

    private

    def publication
      @publication ||= Publication
                       .includes(story: { sections: [:author, :rich_text_rich_body] })
                       .find(params[:publication_id])
    end
  end
end
