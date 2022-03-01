require 'open-uri'

class ZipManifest
  def initialize(manifest: nil)
    @manifest = manifest
  end

  def each_file
    @manifest.each do |contents, filename|
      yield filename, contents
    end
  end

  def self.build(images)
    new(
      manifest:
        images.map do |image|
          [URI.parse(image.url).open, image.filename]
        end
    )
  end
end
