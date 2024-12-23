# frozen_string_literal: true

# Example consumer that prints messages payloads
class OcrConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      Rails.logger.debug message.payload
      # Thought.create(content: message.payload.to_json)
    rescue StandardError => e
      Rails.logger.debug '*' * 88
      # Rails.logger.debug 'kafka message consuption error!!!'
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.join("\n")
      Rails.logger.debug '*' * 88
    end
  end
end
