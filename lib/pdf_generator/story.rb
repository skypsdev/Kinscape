module PdfGenerator
  # rubocop:disable Metrics/ClassLength
  # rubocop:disable Layout/LineLength
  class Story
    def initialize(story)
      @story = story
      @sections = @story.sections.eager_load(:author, :rich_text_rich_body)
    end

    def html_string
      <<~STRING
        <!DOCTYPE html><html lang="en">
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>#{@story.title}</title>#{pdf_style}
          </head>
          <body>
            <div class="title-wrapper">
              <div class="cover-image-wrapper">
                <div class="style-wrapper">
                  <div class="cover-image" style="background-image: url(&quot;#{@story.cover_url(size: :medium)}&quot;);"></div>
                </div>
              </div>
              <div class="title-body">
                <h1>#{@story.title}</h1>
                <div class="meta">
                  <div title="Author" class="author">
                    <div class="face" style="background-image: url(&quot;#{@story.user.avatar_url(size: :thumb)}&quot;);">
                    </div>#{@story.user&.name}
                  </div>#{story_description}
                </div>
              </div>
            </div>
            <div class="table-of-contents-wrapper">
              <h4>Table of Contents</h4>
              <ul class="list">#{table_of_sections}</ul>
            </div>
            <div class="table-of-contents-wrapper">
              #{sections_html}
            </div>
          </body>
        </html>
      STRING
    end

    def table_of_sections
      contents = ''
      @sections.each_with_index do |section, i|
        unless section.title.nil?
          contents += "<li><a href=\"#\">#{i + 1}. #{section.title} </a></li>"
        end
      end
      contents
    end

    def sections_html
      section_html = ''
      @sections.each do |section|
        section_html += "<div class=\"cannot_edit\"><h1>#{section.title}</h1>#{section.rich_body.body}"
        section_html += "<div class=\"section-attribution\"><span class=\"avatar--thumb\" style=\"background-image: url(&quot;#{section.author.avatar_url(size: :thumb)}&quot;);\"></span><span class=\"author-name\">#{section.author&.name}</span></div>" if section.author.present?
        section_html += '</div>'
      end
      section_html
    end

    def story_description
      return '' if @story.description == ''

      '<span title="Description">
        <span class="description"><i class="fa fa-pencil" aria-hidden="true"></i></span>
        ' + @story.description + '
      </span>'
    end

    # rubocop:disable Metrics/MethodLength
    def pdf_style
      '<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
      <style>
        body { font-family: Arial, Helvetica, sans-serif;}
        .title-wrapper {
          max-width: 1200px;
          margin-left: auto;
          margin-right: auto;
          display: table;
          margin-top: 45px;
          margin-bottom: 65px;
          padding: 0em 4em;
          width: 100%;
        }
        .cover-image-wrapper {
          display: table-cell;
          height: 100%;
          padding-right: 3em;
          vertical-align: middle;
          width: 200px;
        }
        .style-wrapper {
          -webkit-transform: rotate(-5deg);
          transform: rotate(-5deg);
          background: #fff;
          box-shadow: 0 0 0 1px rgba(0,0,0,0.15), 0 1px 10px 0 rgba(0,0,0,0.1);
          padding: 0.4em;
        }
        .cover-image {
          height: 200px;
          width: 200px;
          background-position: center center;
          background-repeat: no-repeat;
          background-size: cover;
          box-shadow: inset 0 0 0 1px rgba(0,0,0,0.2);
        }
        .title-body {
          display: table-cell;
          height: 100%;
          padding-bottom: 1em;
          text-align: left;
          vertical-align: middle;
        }
        .title-body h1 {
          font-weight: 300;
          font-size: 4em;
          font-family: "Merriweather", "Georgia", "Cambria", "Times New Roman", "Times", "serif";
          margin-bottom: 0em;
          outline: none;
        }
        .meta {
          color: #647184;
          margin-top: 0.4em;
          text-align: left;
          vertical-align: middle;
        }
        .meta .author{
          color: #647184;
          display: inline-block;
          font-size: 1.2em;
          font-weight: 300;
          line-height: 1.4em;
          margin-bottom: 0.8em;
          margin-right: 1.4em;
          vertical-align: middle;
        }
        .meta .author .face {
          height: 30px;
          width: 30px;
          background-position: 50% 50%;
          background-size: cover;
          border-radius: 50%;
          color: #8c98a8;
          display: inline-block;
          overflow: hidden;
          text-align: center;
          vertical-align: middle;
          background-image: url(avatar-img.svg);
          margin-right: 0.6em;
        }
        .meta>span{
          color: #647184;
          display: inline-block;
          font-size: 1.2em;
          font-weight: 300;
          line-height: 1.4em;
          margin-bottom: 0.8em;
          margin-right: 1.4em;
          vertical-align: middle;
        }
        .meta .description,.meta .dates, .meta .tags{
          height: 30px;
          width: 30px;
          background: rgba(255,255,255,0.9);
          border: 1px solid #dbe0e7;
          border-radius: 50%;
          display: inline-block;
          font-family: "FontAwesome";
          font-size: 0.8em;
          line-height: 30px;
          margin-right: 0.6em;
          text-align: center;
        }
        .content-area { padding: 25px 0px;}
        h4 {
          font-size: 1.2em;
          font-weight: normal;
          padding-bottom: 1em;
        }
        .table-of-contents-wrapper {
          max-width: 1200px;
          margin-left: auto;
          margin-right: auto;
          margin-bottom: 80px;
          padding: 0 4em;
          position: relative;
        }
        h4 { margin: 0px;}
        ul.list { margin: 0px; padding: 0px;}
        ul.list li { list-style: none; margin-bottom: 5px;}
        ul.list li a{ color: #8c98a8; font-size: 16px; text-decoration: none;}
        .cannot_edit {
          max-width: 1200px;
          margin-left: auto;
          margin-right: auto;
          margin-bottom: 15px;
          padding: 20px 2em;
          position: relative;
          background-color: #ebf2fc;
          border-radius: 5px;
        }
        .trix-content {
          padding: 0px 2em;
          padding-top: 15px;
          color: #647184;
          font-size: 1.2rem
        }
        .trix-content h1 {
          font-weight: 300;
          margin: 0px;
          padding-bottom: 10px;
          color: #293439;
          font-size: 2.88rem !important;
        }
        .trix-content p { margin: 0px; padding: 0px; padding-top: 10px; padding-bottom: 5px;}
        .trix-content a.download-doc {
          background-color: white;
          border: 1px solid #dbe0e7;
          box-shadow: 0 1px 10px 0 rgba(0,0,0,0.06);
          padding: 1rem;
          text-decoration: none !important;
          font-size: 1rem !important;
          display: block;
          color: #8c98a8;
          padding-right: 2em;
          position: relative;
          text-align: left;
          line-height: 1.5rem !important;
        }
        .cloud-img {color: #d2d2d2; float: right; font-size: 18px; margin-top: 5px;}
        .mr-2 { margin-right: 5px;}
        .section-attribution {
          margin-top: 5px;
          text-align: right;
          font-weight: 600;
          font-size: 13px;
          display: flex;
          align-items: center;
          justify-content: flex-end;
        }
        .avatar--thumb {
          width: 30px;
          height: 30px;
          background-image: url(avatar-img.svg);
          background-position: 50% 50%;
          background-size: cover;
          border-radius: 50%;
          display: inline-block;
          overflow: hidden;
          text-align: center;
          vertical-align: middle;
          margin-right: 0.6em;
        }
        .author-name {
          margin-right: 8px;
          color: #000;
        }
        .date::before {
          display: inline-block;
          content: "";
          margin-right: 8px;
          margin-bottom: 2px;
          width: 4px;
          height: 4px;
          border-radius: 50%;
          background-color: #8c98a8;
          vertical-align: middle;
        }
        .attachment-gallery {
          display: flex;
          flex-wrap: wrap;
          position: relative;
          margin: 0;
          padding: 0;
        }
        .trix-content img {
          max-width: 100%;
          height: auto;
        }
        .trix-content .attachment-gallery > action-text-attachment, .trix-content .attachment-gallery > .attachment {
          -webkit-box-flex: 1;
          -ms-flex: 1 0 33%;
          flex: 1 0 33%;
          padding: 0 0.5em;
          max-width: 33%;
          display: inline-block;
        }
      </style>'
    end
    # rubocop:enable Metrics/MethodLength
  end
end
# rubocop:enable Layout/LineLength
# rubocop:enable Metrics/ClassLength
