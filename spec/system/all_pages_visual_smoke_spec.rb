# frozen_string_literal: true

require "rails_helper"

RSpec.describe "All primary pages", type: :system, playwright: true do
  # Playwright drives the app through Capybara's Puma server thread, so records
  # need to be committed before the browser requests each page and cleaned here.
  self.use_transactional_tests = false

  VIEWPORTS = {
    desktop: { width: 1365, height: 900 },
    mobile: { width: 390, height: 844 }
  }.freeze

  let(:uuid) { "3ae6a420-9de3-4088-9fad-301de9932251" }
  let(:group_id) { "#{uuid}~1" }
  let(:post_record) { create(:post) }
  let(:comment_record) { create(:comment) }
  let(:active_storage_post) { create(:active_storage_post) }

  let(:files_accessor) { double("UploadcareFilesAccessor") }
  let(:groups_accessor) { double("UploadcareGroupsAccessor") }
  let(:project_accessor) { double("UploadcareProjectAccessor") }
  let(:webhooks_accessor) { double("UploadcareWebhooksAccessor") }
  let(:metadata_accessor) { double("UploadcareFileMetadataAccessor") }
  let(:documents_accessor) { double("UploadcareDocumentConversionsAccessor") }
  let(:videos_accessor) { double("UploadcareVideoConversionsAccessor") }
  let(:conversions_accessor) { double("UploadcareConversionsAccessor", documents: documents_accessor, videos: videos_accessor) }
  let(:addons_accessor) { double("UploadcareAddonsAccessor") }
  let(:client) { Uploadcare::Client.new(public_key: "demopublickey", secret_key: "demoprivatekey") }

  before do
    Post.delete_all
    Comment.delete_all
    ActiveStoragePost.delete_all

    post_record
    comment_record
    active_storage_post

    stub_uploadcare_client(client)
    stub_uploadcare_client_accessors
    stub_uploadcare_resources
    stub_model_uploadcare_attachments
  end

  after do
    Post.delete_all
    Comment.delete_all
    ActiveStoragePost.delete_all
  end

  it "renders every primary page at desktop and mobile widths with the current asset pipeline" do
    VIEWPORTS.each do |viewport, size|
      resize_to(size)

      primary_pages.each do |label, path, expected_text|
        visit path

        aggregate_failures("#{viewport} #{label}") do
          expect(page).to have_text(expected_text)
          expect(page).to have_css("main")
          expect(page).to have_css("link[href*='tailwind']", visible: :all)

          expect(layout_metrics.fetch("main_top")).to be < layout_metrics.fetch("aside_top") if viewport == :mobile
        end

        save_visual_snapshot(viewport, label) if ENV["VISUAL_SNAPSHOTS"] == "1"
      end
    end
  end

  private

  def primary_pages
    [
      [ "root", root_path, "Project Info" ],
      [ "project", project_path, "Project Info" ],
      [ "examples", examples_path, "Examples" ],
      [ "uploader helper examples", uploader_fields_examples_path, "Uploader Helper Examples" ],
      [ "files index", files_path, "List files" ],
      [ "file show", file_path(uuid), "File papaya.jpg info" ],
      [ "batch store files", new_store_file_batch_path, "Batch store file" ],
      [ "batch delete files", new_delete_file_batch_path, "Batch delete file" ],
      [ "local upload", upload_new_local_file_path, "Upload a local file" ],
      [ "url upload", upload_new_file_from_url_path, "Upload a file from URL" ],
      [ "file groups index", file_groups_path, "List files" ],
      [ "new file group", new_file_group_path, "Create group of files" ],
      [ "file group show", file_group_path(group_id), "Group info" ],
      [ "document conversion info form", new_document_conversion_information_path, "Conversion formats info" ],
      [ "document conversion info result", document_conversion_information_path(file: uuid), "Conversion formats info" ],
      [ "document conversion form", new_document_conversion_path, "Document conversion" ],
      [ "document conversion status", document_conversion_path(token: "doc-token", original_source: "#{uuid}/document/"), "Document conversion result" ],
      [ "document conversion problem", document_conversion_path(problem_source: "#{uuid}/document/", problem_reason: "Conversion failed"), "Document conversion result" ],
      [ "video conversion form", new_video_conversion_path, "Video conversion" ],
      [ "video conversion status", video_conversion_path(token: "video-token", original_source: "#{uuid}/video/", thumbnails_group_uuid: group_id), "Video conversion result" ],
      [ "video conversion problem", video_conversion_path(problem_source: "#{uuid}/video/", problem_reason: "Conversion failed"), "Video conversion result" ],
      [ "webhooks index", webhooks_path, "Webhooks list" ],
      [ "new webhook", new_webhook_path, "Create a new webhook" ],
      [ "webhook show", webhook_path(816_965), "Webhook ID 816965 info" ],
      [ "webhook edit", edit_webhook_path(816_965), "Edit webhook" ],
      [ "posts index", posts_path, "Posts" ],
      [ "new post", new_post_path, "Create a new post" ],
      [ "post show", post_path(post_record), "Post" ],
      [ "post edit", edit_post_path(post_record), "Edit post" ],
      [ "active storage posts index", active_storage_posts_path, "Active Storage posts" ],
      [ "new active storage post", new_active_storage_post_path, "Create a new Active Storage post" ],
      [ "active storage post show", active_storage_post_path(active_storage_post), "Active Storage post" ],
      [ "active storage post edit", edit_active_storage_post_path(active_storage_post), "Edit Active Storage post" ],
      [ "comments index", comments_path, "Comments" ],
      [ "new comment", new_comment_path, "Create a new comment" ],
      [ "comment show", comment_path(comment_record), "Comment" ],
      [ "comment edit", edit_comment_path(comment_record), "Edit comment" ],
      [ "file metadata index", file_metadata_path, "Select file" ],
      [ "all file metadata", all_metadata_show_file_metadata_path(uuid: uuid), "uuid: #{uuid}" ],
      [ "single file metadata", metadata_show_file_metadata_path(uuid: uuid, key: "kind"), "key: kind" ],
      [ "virus scan index", virus_scan_index_path(uuid: "virus-request"), "virus-request" ],
      [ "new virus scan", new_virus_scan_path, "Check file on virus" ],
      [ "virus scan status", show_status_virus_scan_index_path(status: "done"), "done" ],
      [ "rekognition labels index", rekognition_labels_path(uuid: "labels-request"), "labels-request" ],
      [ "new rekognition labels", new_rekognition_label_path, "Rekognition file labels" ],
      [ "rekognition labels status", show_status_rekognition_labels_path(status: "done"), "done" ],
      [ "remove bg index", remove_bg_index_path(uuid: "remove-bg-request"), "remove-bg-request" ],
      [ "new remove bg", new_remove_bg_path, "Remove file background" ],
      [ "remove bg status", show_status_remove_bg_index_path(status: "done"), "done" ],
      [ "rekognition moderation labels index", rekognition_moderation_labels_path(uuid: "moderation-request"), "moderation-request" ],
      [ "new rekognition moderation labels", new_rekognition_moderation_label_path, "Rekognition moderation file labels" ],
      [ "rekognition moderation labels status", show_status_rekognition_moderation_labels_path(status: "done"), "done" ]
    ]
  end

  def stub_uploadcare_resources
    allow(files_accessor).to receive(:list).and_return(uploadcare_paginated(uploadcare_file))
    allow(files_accessor).to receive(:find).with(uuid: uuid).and_return(uploadcare_file)
    allow(groups_accessor).to receive(:list).and_return(uploadcare_paginated(file_group))
    allow(groups_accessor).to receive(:find).with(group_id: group_id).and_return(file_group)
    allow(project_accessor).to receive(:current).and_return(project)
    allow(webhooks_accessor).to receive(:list).and_return([ webhook ])
    allow(metadata_accessor).to receive(:index).with(uuid: uuid).and_return("kind" => "fruit")
    allow(metadata_accessor).to receive(:show).with(uuid: uuid, key: "kind").and_return("fruit")
    allow(documents_accessor).to receive(:info).with(uuid: uuid).and_return(document_info)
    allow(documents_accessor).to receive(:status).with(token: "doc-token").and_return(conversion_status)
    allow(videos_accessor).to receive(:status).with(token: "video-token").and_return(conversion_status)
  end

  def stub_uploadcare_client_accessors
    allow(client).to receive(:files).and_return(files_accessor)
    allow(client).to receive(:groups).and_return(groups_accessor)
    allow(client).to receive(:project).and_return(project_accessor)
    allow(client).to receive(:webhooks).and_return(webhooks_accessor)
    allow(client).to receive(:file_metadata).and_return(metadata_accessor)
    allow(client).to receive(:conversions).and_return(conversions_accessor)
    allow(client).to receive(:addons).and_return(addons_accessor)
  end

  def stub_model_uploadcare_attachments
    # These examples cover rendered pages, not Uploadcare attachment loading.
    # Stubbing at the controller boundary keeps the smoke test network-free.
    allow_any_instance_of(PostsController).to receive(:load_group_files).and_return([ uploadcare_file ])
    allow_any_instance_of(CommentsController).to receive(:load_group_files).and_return([ uploadcare_file ])
    allow_any_instance_of(Uploadcare::Rails::AttachedFile).to receive(:load).and_return(attached_uploadcare_file)
  end

  def project
    Uploadcare::Project.new(
      {
        "collaborators" => [ { "name" => "Mike", "email" => "mike@example.com" } ],
        "name" => "Example project",
        "pub_key" => "demopublickey",
        "autostore_enabled" => true
      },
      Uploadcare.client
    )
  end

  def uploadcare_file
    Uploadcare::File.new(
      {
        "datetime_removed" => nil,
        "datetime_uploaded" => "2026-05-18T12:30:00Z",
        "content_info" => {
          "image" => {
            "color_mode" => "RGB",
            "orientation" => nil,
            "format" => "JPEG",
            "sequence" => false,
            "height" => 500,
            "width" => 500,
            "geo_location" => nil,
            "dpi" => [ 144, 144 ]
          }
        },
        "is_image" => true,
        "is_ready" => true,
        "mime_type" => "image/jpeg",
        "original_file_url" => "https://ucarecdn.com/#{uuid}/papaya.jpg",
        "original_filename" => "papaya.jpg",
        "size" => 642,
        "url" => "https://api.uploadcare.com/files/#{uuid}/",
        "uuid" => uuid,
        "variations" => nil,
        "metadata" => { "kind" => "fruit" }
      },
      Uploadcare.client
    )
  end

  def attached_uploadcare_file
    Uploadcare::Rails::AttachedFile.new(
      {
        "uuid" => uuid,
        "cdn_url" => "https://ucarecdn.com/#{uuid}/",
        "original_filename" => "papaya.jpg",
        "mime_type" => "image/jpeg"
      }
    )
  end

  def file_group
    Uploadcare::Group.new(
      {
        "id" => group_id,
        "datetime_created" => "2026-05-18T12:30:00Z",
        "files_count" => 1,
        "cdn_url" => "https://ucarecdn.com/#{group_id}/",
        "url" => "https://api.uploadcare.com/groups/#{group_id}/",
        "files" => [
          {
            "uuid" => uuid,
            "original_filename" => "papaya.jpg",
            "mime_type" => "image/jpeg"
          }
        ]
      },
      Uploadcare.client
    )
  end

  def webhook
    Uploadcare::Webhook.new(
      {
        "id" => 816_965,
        "created" => "2026-05-18T12:30:00Z",
        "updated" => "2026-05-18T12:35:00Z",
        "event" => "file.uploaded",
        "target_url" => "https://example.com/uploadcare",
        "project" => 123_681,
        "is_active" => true
      },
      Uploadcare.client
    )
  end

  def document_info
    double(
      "DocumentConversionInfo",
      format: {
        "name" => "pdf",
        "conversion_formats" => [ { "name" => "docx" } ],
        "converted_groups" => { "docx" => group_id }
      }
    )
  end

  def conversion_status
    double("ConversionStatus", status: "finished", error: nil, result: [ { "uuid" => uuid } ])
  end

  def resize_to(size)
    page.driver.with_playwright_page do |playwright_page|
      playwright_page.viewport_size = size
    end
  end

  def layout_metrics
    page.evaluate_script(<<~JS)
      (() => {
        const main = document.querySelector("main").getBoundingClientRect();
        const aside = document.querySelector("aside").getBoundingClientRect();

        return {
          main_top: main.top,
          aside_top: aside.top
        };
      })()
    JS
  end

  def save_visual_snapshot(viewport, label)
    screenshot_dir = Rails.root.join("tmp/playwright-pages")
    FileUtils.mkdir_p(screenshot_dir)
    page.save_screenshot(screenshot_dir.join("#{viewport}-#{label.parameterize}.png"))
  end
end
