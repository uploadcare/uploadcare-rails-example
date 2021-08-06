# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'validation' do
    it 'is not valid without a title' do
      post = build(:post, title: nil)
      expect(post).to_not be_valid
    end

    it 'is valid with a title' do
      post = build(:post, title: 'some')
      expect(post).to be_valid
    end
  end
end
