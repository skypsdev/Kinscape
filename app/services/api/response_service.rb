module Api
  class ResponseService
    def initialize(context, current_user = nil)
      @context = context
      @current_user = current_user
    end

    def render_collection(serializer, object, options: {})
      if Rails.env.in?(%w[development test])
        raise 'Options must be a Hash' unless options.is_a?(Hash)
        raise 'use `Api::ResponseService.render` method' if object.respond_to?(:errors)
      end

      options[:params] ||= {}
      options[:params][:current_user] = @current_user
      @context.render json: serializer.new(object, options).to_json
    end

    def render(serializer, object, options: {})
      if Rails.env.in?(%w[development test])
        raise 'Options must be a Hash' unless options.is_a?(Hash)
        raise 'use `Api::ResponseService.render_collection` method' unless object.respond_to?(:errors)
      end
      return render_error(object.errors.full_messages) if object.invalid?

      options[:params] ||= {}
      options[:params][:current_user] = @current_user
      @context.render json: serializer.new(object, options).to_json
    end

    def render_no_content
      @context.head :no_content
    end

    def render_error(errors)
      @context.render(
        json: {
          errors: {
            status: 422,
            title: 'Invalid Attribute',
            detail: errors
          }
        },
        status: :unprocessable_entity
      )
    end

    def render_not_found
      @context.render json: { message: 'not found' }, status: :not_found
    end

    def render_unauthorized
      @context.render json: { message: 'unauthorized' }, status: :unauthorized
    end

    def render_forbidden(message = nil)
      @context.render json: { message: message || 'forbidden' }, status: :forbidden
    end
  end
end
