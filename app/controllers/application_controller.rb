# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :check_header

  private

  def check_header
    return unless %w[POST PUT PATCH].include? request.method

    head(406) && return if request.content_type != 'application/vnd.api+json'
  end

  def validate_type
    if params['data'] && params['data']['type']
      return true if params['data']['type'] == params[:controller]
    end
    head(409) && return
  end

  def validate_user
    token = request.headers['X-Api-Key']
    head(403) && return unless token
    user = User.find_by token: token
    head(403) && return unless user
  end

  def render_error(resource, status)
    render json: resource, status: status, adapter: :json_api,
           serializer: ActiveModel::Serializer::ErrorSerializer
  end
end
