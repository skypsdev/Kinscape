module Uid
  extend ActiveSupport::Concern

  included do
    validates :uuid, uniqueness: true

    after_initialize :set_defaults
  end

  def uid
    uuid.base62_encode
  end

  def uid=(str)
    self.uuid = str.base62_decode
  end

  def set_defaults
    self.uuid ||= UuidService.generate
  end

  class_methods do
    def find_all_by_uid(uids)
      where(uuid: Array.wrap(uids).map(&:base62_decode))
    rescue NoMethodError
      # when uid is not a valid base62 string
      nil
    end

    def find_by_uid(uid)
      find_by(uuid: uid.base62_decode)
    rescue NoMethodError
      # when uid is not a valid base62 string
      nil
    end

    def find_by_uid!(uid)
      find_by!(uuid: uid.base62_decode)
    rescue NoMethodError
      # when uid is not a valid base62 string
      raise ActiveRecord::RecordNotFound
    end
  end
end
