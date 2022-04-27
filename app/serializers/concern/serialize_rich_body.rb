module Concern
  module SerializeRichBody
    class << self
      def attributes_hash(editor_body)
        {
          body: prepare_body(editor_body.try(:to_trix_html)),
          html: prepare_html(editor_body.to_s)
        }
      end

      private

      def prepare_body(body)
        section_body = Nokogiri::HTML.fragment(body)
        section_body.at('h1')&.remove
        section_body.at('h3')&.remove
        attachments = section_body.xpath('.//figure')
        attachments.each do |a|
          a_json = JSON.parse(a['data-trix-attachment'])
          a_json['url'] = service_url_signed_id(a_json)
          a_json['previewable'] = false if a_json['contentType'].include?('video')
          a['data-trix-attachment'] = a_json.to_json
        end
        section_body.to_html.delete("\n")
      end

      def prepare_html(body)
        section_html = Nokogiri::HTML.fragment(body)
        section_html.at('h1')&.remove
        section_html.at('h3')&.remove
        section_html.to_s.delete("\n")
      end

      def service_url_signed_id(data)
        # TODO: refactor trix editor file saving, prepare a rake task to fix current data
        # and use just one way of blob searching
        blob = GlobalID::Locator.public_send(:locate_signed, data['sgid'], { for: 'attachable' })
        blob ||= ActiveStorage::Blob.find_signed(data['url'])
        Rails.application.routes.url_helpers.rails_blob_url(blob, only_path: true)
      rescue StandardError
        data['url']
      end
    end
  end
end
