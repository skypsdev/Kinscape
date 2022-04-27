class Appreciation
  class CreationService < ApplicationService
    def initialize(current_user, params, publication: nil)
      @current_user = current_user
      @params = params
      @publication = publication
    end

    def call
      @appreciation = appreciable.appreciations.build(user: current_user, reaction: params[:reaction])
      if @appreciation.save
        if publication
          ::Stories::NotificationService.notify_appreciation(appreciable, current_user, publication.id)
        elsif appreciable.chapterable_type == 'Family'
          # family = appreciable.chapterable_type.constantize.find_by(id: appreciable.chapterable_id)
          # template = :appreciate_on_profile_chapter
          # params = { family: family, chapter: appreciable }
          # ::MailerService.call(template, params: params)
        elsif appreciable.chapterable_type == 'Kinship'
          ::Kinships::NotificationService.notify_appreciation(appreciable)
        end
      end
      @appreciation
    end

    private

    def appreciable
      params[:appreciable_type].constantize.find_by(id: params[:appreciable_id])
    end

    attr_reader :params, :current_user, :publication
  end
end
