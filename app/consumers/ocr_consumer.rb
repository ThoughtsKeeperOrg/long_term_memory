# frozen_string_literal: true

# Example consumer that prints messages payloads
class OcrConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      # Rails.logger.debug message.payload
      p message

      # if message.payload['status'] == 'scanned'

      thought = Image.find(message.key).thought
      thought.content += message.payload['text']
      thought.save
      # else
      #   # TODO
      # end
      # Thought.create(content: message.payload.to_json)
    rescue StandardError => e
      p '*' * 88
      # p 'kafka message consuption error!!!'
      p e.message
      p e.backtrace.join("\n")
      p '*' * 88
    end
  end
end
