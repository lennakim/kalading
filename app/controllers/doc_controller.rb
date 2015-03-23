class DocController < ApplicationController

  if Rails.env.production?
    http_basic_authenticate_with name: "kalading", password: "secret"
  end

  def v2

  end
end
