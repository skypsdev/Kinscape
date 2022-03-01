class UserAccountDeleteJob < ApplicationJob
  queue_as :default

  def perform(user)
    user.families.each do |family|
      family.stories.each do |story|
        story.user != user &&
          story.delete_all_contents_by_author(user)
      end
    end

    user.boxes.destroy_all
    user.subscriptions.destroy_all
    user.comments.destroy_all
    user.families.destroy_all
    user.kinships.destroy_all
    user.stories.destroy_all
    user.sections.destroy_all

    Vault.where(owner: user).destroy_all
    Family.where(admin: user).destroy_all
    MediaFile.where(user: user).each do |media_file|
      media_file.attachments.destroy_all
      media_file.destroy
    end

    user.destroy
  end
end
