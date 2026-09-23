# frozen_string_literal: true

module Website
  class Enquiry
    include ActiveModel::Model

    attr_accessor :topic, :name, :email, :organisation, :timescale, :message, :privacy

    TOPICS = [
      'Strategy & Transformation',
      'Data & Analytics',
      'Technology & Solutions',
      'Programme & Project Delivery',
      'Summer internships',
      'Something else'
    ].freeze

    TIMESCALES = [
      'Not sure yet',
      'This quarter',
      'This year',
      'Exploratory'
    ].freeze

    validates :name, :email, :message, presence: true
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
    validates :privacy, acceptance: { accept: ['1', 1, true, 'true', 'on'] }
  end
end
