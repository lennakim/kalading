class DocController < ApplicationController

  layout "api"

  if Rails.env.production? || Rails.env.staging?
    http_basic_authenticate_with name: "kalading", password: "secret"
  end

  def v2

  end
end
