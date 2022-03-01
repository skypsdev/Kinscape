# frozen_string_literal: true

require 'spec_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      components: {
        securitySchemes: {
          cookie: {
            type: :apiKey,
            name: 'cookie',
            in: :header,
            description: 'use remember_token_development'
          }
        }
      },
      info: {
        title: 'API V1',
        version: 'v1'
      },
      consumes: ['application/json'],
      produces: ['application/json'],
      paths: {},
      servers: [
        {
          url: 'http://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'localhost:3000'
            }
          }
        }
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml

  config.after do |example|
    condition = example.metadata[:type] == :request &&
                response.body.present? &&
                response.headers['Content-Disposition']&.exclude?('attachment')
    if condition
      # save example response
      example.metadata[:response][:content] = { 'application/json' => { example: response.parsed_body } }

      request_example_name = example.metadata[:save_request_example]

      # save example payload params
      if request_example_name && respond_to?(request_example_name)
        param = example.metadata[:operation][:parameters].find { |p| p[:name] == request_example_name }
        param[:schema][:example] = send(request_example_name)
      end

      # save example query params
      if request_example_name
        params = example.metadata[:operation][:parameters].find_all { |p| p[:in] == :query }
        params.each do |p|
          value = send(p[:name])
          next unless value

          p[:schema] ||= {}
          p[:schema][:example] = value
        end
      end
    end
  end
end
