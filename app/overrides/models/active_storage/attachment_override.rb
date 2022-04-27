ActiveStorage::Attachment.class_eval do
  belongs_to :box, optional: true
  belongs_to :user, optional: true
  belongs_to :family, optional: true

  after_create_commit :convert_file

  private

  def convert_file
    if video? || audio?
      ActiveStorage::ConvertAudioVideoJob.perform_later(id)
    elsif image?
      ActiveStorage::ProcessImageVariantJob.perform_later(id)
    end
  end
end
