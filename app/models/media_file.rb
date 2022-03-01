# == Schema Information
#
# Table name: media_files
#
#  id             :integer          not null, primary key
#  mimetype       :string
#  url            :text             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  filename       :text             default(""), not null
#  key            :string           default(""), not null
#  type           :string
#  height         :integer
#  width          :integer
#  converted_urls :hstore
#  user_id        :integer
#  size           :integer
#  title          :string
#

require Rails.root.join('lib/s3_config')
require 'open-uri'

class MediaFile < ApplicationRecord
  # Disables STI
  self.inheritance_column = :_type_disabled

  include ActionText::Attachable

  has_many :attachments, dependent: :destroy
  has_many :sections, through: :attachments,
                      source: :containable,
                      source_type: 'Section'

  belongs_to :user, optional: true

  validates :url, presence: true, format: URI::DEFAULT_PARSER.make_regexp(%w(http https))

  after_save :set_mimetype_in_background, unless: :mimetype?

  scope :images, -> { where(type: 'Image') }

  def self.mimetype_from_path(url)
    URI.parse(url).open.content_type
  end

  def s3_url
    "#{s3_base}/#{s3_bucket}/#{key}"
  end

  def cdn_url(format: nil)
    if format.nil?
      "#{s3_config.cloudfront_endpoint}/#{escape_url(key)}"
    elsif converted_urls.with_indifferent_access[format.to_s]
      filename = converted_urls.with_indifferent_access[format.to_s]
      if URI.parse(escape_url(filename)).host
        filename
      else
        converted_url = escape_url(filename)
        converted_url = "/#{converted_url}" unless converted_url[0] == '/'
        "#{s3_config.cloudfront_endpoint}#{converted_url}"
      end
    else
      key.present? ? s3_url : url
    end
  end

  def s3_bucket
    s3_config.bucket
  end

  def s3_base
    s3_config.base_url
  end

  def story
    sections.first.story
  end

  def user
    sections.first&.user
  end

  # Hack so our serializers don't think it's a Hash (because of #size)
  def each_pair; end

  private

  def s3_config
    S3Config.instance
  end

  def set_mimetype_in_background
    return if Rails.env.test?

    delay.set_mimetype_from_path
  end

  def set_mimetype_from_path
    update_attribute(:mimetype, self.class.mimetype_from_path(url))
  end

  def escape_url(url)
    URI::DEFAULT_PARSER
      .escape(url)
      .gsub(/\(/, '%28')
      .gsub(/\)/, '%29')
      .gsub(/\[/, '%5B')
      .gsub(/\]/, '%5D')
  end
end
