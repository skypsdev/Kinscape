class UserAccountDeleteJob < ApplicationJob
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
    user.all_kinships.destroy_all
    user.stories.destroy_all
    user.sections.destroy_all

    Vault.where(owner: user).destroy_all
    Family.where(admin: user).destroy_all

    user.destroy
  end
end
