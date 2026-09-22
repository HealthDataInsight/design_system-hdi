# frozen_string_literal: true

module Website
  class Enquiry
    include ActiveModel::Model

    attr_accessor :topic, :name, :organisation, :message

    TOPICS = [
      'Strategy & Transformation',
      'Data & Analytics',
      'Technology & Solutions',
      'Programme & Project Delivery',
      'Something else'
    ].freeze

    validates :name, :message, presence: true
  end
end
