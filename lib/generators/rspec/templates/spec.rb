require 'swagger_helper'

RSpec.describe <%= @name.constantize %>, type: :request do
  let(:user) { create :user }
  let!(:family) { create :family, users: [user] }
  let(:id) { 'UPDATE_ME_ID' }
<%  @routes.each do | template, path_item | %>
  path '<%= template %>' do
<%    unless path_item[:params].empty? -%>
<%      path_item[:params].each do |param| -%>
    parameter name: '<%= param %>', in: :path, type: :string
<%      end -%>
<%      path_item[:params].each do |param| -%>
<%        next if param == 'id' -%>
    let(:<%= param %>) { 'UPDATE_ME_PARAM' }
<%      end -%>
<%    end -%>
<%    path_item[:actions].each do | action, details | %>
    <%= action %>('<%= details[:summary] %>') do
      include_context 'cookie'
      tags '<%= controller_path.split('/').last.singularize.humanize %>'

<%   if action.in?(['put', 'post', 'patch']) -%>
      <%= "parameter name: :payload, in: :body, schema: {" %>
        <%= "type: :object," %>
        <%= "properties: {" %>
          <%= "update_me_param: { type: :string }" %>
        <%= "}," %>
        <%= "required: %w[update_me_param]" %>
      <%= "}" %>
      <%= "let(:payload) do" %>
        <%= "{" %>
          <%= "update_me_param: update_me_value" %>
        <%= "}" %>
      <%= "end" %>
<%    end -%>
<%    if action == 'delete' -%>
      <%= "response(204, 'successful') do" %>
<%    elsif action.in?(['put', 'post', 'patch']) -%>
      <%= "response(200, 'successful', save_request_example: :payload) do" %>
<%    else -%>
      <%= "response(200, 'successful') do" %>
<%    end -%>
<%    if action == 'delete' -%>
        <%= "before do" %>
          <%= "expect(#{controller_path.split('/').last.singularize.capitalize}.count).to eq(1)" %>
        <%= "end" %>
        <%= "run_test! do" %>
          <%= "expect(#{controller_path.split('/').last.singularize.capitalize}.count).to eq(0)" %>
        <%= "end" %>
<%    else -%>
        <%= "run_test! do" %>
          <%= "expect(response.parsed_body).to eq('UPDATE_ME_RESPONSE')" %>
        <%= "end" %>
<%    end -%>
      end
    end
<%    end -%>
  end
<%  end -%>
end
