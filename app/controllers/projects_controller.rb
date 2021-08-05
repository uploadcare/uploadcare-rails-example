# frozen_string_literal: true

class ProjectsController < ApplicationController
  def show
    @project = Uploadcare::ProjectApi.get_project
  end
end
