require 'rails'
require 'active_record/railtie'

require 'action_text'

module EncryptedActionText
  class Engine < ::Rails::Engine
    isolate_namespace EncryptedActionText

    config.eager_load_namespaces << EncryptedActionText

    initializer 'encrypted_action_text.attribute' do
      ActiveSupport.on_load(:active_record) do
        include EncryptedActionText::Attribute
      end
    end

    initializer 'encrypted_action_text.renderer' do |app|
      app.executor.to_run do
        EncryptedActionText::Content.renderer = ApplicationController.renderer
      end
      app.executor.to_complete do
        EncryptedActionText::Content.renderer = ApplicationController.renderer
      end

      ActiveSupport.on_load(:action_text_content) do
        self.renderer = ApplicationController.renderer
      end

      ActiveSupport.on_load(:action_controller_base) do
        before_action do
          EncryptedActionText::Content.renderer =
            ApplicationController.renderer.new(request.env)
        end
      end
    end
  end
end
