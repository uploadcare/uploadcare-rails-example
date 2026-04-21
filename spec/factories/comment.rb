# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    content { "Useful comment" }
    image { "https://ucarecdn.com/e091bd31-1241-4e9a-8b61-79e080ceaa1a/" }
    attachments { "https://ucarecdn.com/dc96d711-e6cc-40c6-b688-558cf2198664~2/" }
  end
end
