# frozen_string_literal: true

class ProjectsController < ApplicationController
  def show
    @project = uploadcare_client.project.current
  end
end
