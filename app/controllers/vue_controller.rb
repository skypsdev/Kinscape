class VueController < ApplicationController
  def show
    # rubocop:disable Rails/RenderInline
    render inline: '', layout: 'vue-application'
    # rubocop:enable Rails/RenderInline
  end
end
