module FormErrorsHelper
  def error_message_on(object, method)
    return unless object.respond_to?(:errors)
    return unless object.errors.include?(method)

    render 'users/error', message: object.errors[method].uniq.map(&:humanize).to_sentence
  end
end
