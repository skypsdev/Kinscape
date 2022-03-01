ActiveSupport.on_load(:active_storage_attachment) do
  ActiveStorage::Attachment.class_eval do
    belongs_to :box, optional: true
    belongs_to :user, optional: true
    belongs_to :family, optional: true

    after_create_commit :convert_file

    private

    def convert_file
      ActiveStorage::ConvertVideoJob.perform_later(self) if video?
    end
  end
end
