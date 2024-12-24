# frozen_string_literal: true

# Example consumer that prints messages payloads
class OcrConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      Rails.logger.debug message.payload
      p message

      image = Image.find(message.key)

      if message.payload['status'] == 'scanned'
        p 's'*88

        thought = image.thought
        thought.content += message.payload['text']
        thought.save
      else
        p 'e'*88

        # TODO
      end
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
