require 'base62'

class UuidService
  LIMIT = 9_223_372_036_854_775_800 # Postgres limit

  def self.generate
    rand(LIMIT)
  end

  def self.generate_fallback_uuids!(klass)
    klass.transaction do
      klass.find_each do |s|
        s.uuid = Base62.decode(s.id.to_s)
        s.save
      end
    end
  end
end
