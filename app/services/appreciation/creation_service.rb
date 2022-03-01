class Appreciation
  class CreationService < ApplicationService
    def initialize(current_user, publication, attributes)
      @current_user = current_user
      @attributes = attributes
      @publication = publication
    end

    def call
      @appreciation = publication.appreciations.build(user: current_user, reaction: attributes[:reaction])
      ::Stories::NotificationService.notify_appreciation(publication, current_user) if @appreciation.save
      @appreciation
    end

    private

    attr_reader :attributes, :current_user, :publication
  end
end
