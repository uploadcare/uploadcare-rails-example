# frozen_string_literal: true

class ExamplesController < ApplicationController
  def index
    @example_groups = [
      {
        title: "Core API operations",
        links: [
          [ "Project info", project_path ],
          [ "Files", files_path ],
          [ "File groups", file_groups_path ],
          [ "Upload local file", upload_new_local_file_path ],
          [ "Upload file from URL", upload_new_file_from_url_path ]
        ]
      },
      {
        title: "Conversions and add-ons",
        links: [
          [ "Document conversion formats info", new_document_conversion_information_path ],
          [ "Convert document", new_document_conversion_path ],
          [ "Convert video", new_video_conversion_path ],
          [ "Virus scan", new_virus_scan_path ],
          [ "Rekognition labels", new_rekognition_label_path ],
          [ "Rekognition moderation labels", new_rekognition_moderation_label_path ],
          [ "Remove background", new_remove_bg_path ]
        ]
      },
      {
        title: "Metadata and webhooks",
        links: [
          [ "Metadata", file_metadata_path ],
          [ "Webhooks", webhooks_path ],
          [ "Create webhook", new_webhook_path ]
        ]
      },
      {
        title: "Model and storage integrations",
        links: [
          [ "Posts (ActiveRecord)", posts_path ],
          [ "Comments (Mongoid)", comments_path ],
          [ "Active Storage posts", active_storage_posts_path ]
        ]
      },
      {
        title: "Uploader field helper APIs",
        links: [
          [ "Uploader helper examples", uploader_fields_examples_path ]
        ]
      }
    ]
  end

  def uploader_fields
    @post = Post.new(logo: post_params[:logo], attachments: post_params[:attachments])
    @standalone_logo = params[:standalone_logo]
    @standalone_attachments = params[:standalone_attachments]
    @submitted = request.post?
  end

  private

  def post_params
    params.fetch(:post, {}).permit(:logo, :attachments)
  end
end
