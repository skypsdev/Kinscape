module Stories
  class DownloadsController < ApplicationController
    def show
      authorize! :read, story
      send_file(
        ::Stories::GenerateZipService.call(story),
        type: 'application/zip',
        filename: "story-##{story.uid}-files.zip"
      )
    end

    private

    def story
      @story ||= Story.includes(sections: [:author, :rich_text_rich_body]).find_by_uid!(params[:story_id])
    end
  end
end
