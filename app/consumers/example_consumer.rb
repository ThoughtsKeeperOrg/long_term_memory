# frozen_string_literal: true

# Example consumer that prints messages payloads
class ExampleConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      puts message.payload
      Thought.create(content: message.payload.to_json)
    rescue StandardError => e
      p '*' * 88
      p 'kafka message consuption error!!!'
      p e.message
      p e.backtrace.join("\n")
      p '*' * 88
    end
  end

  # Run anything upon partition being revoked
  # def revoked
  # end

  # Define here any teardown things you want when Karafka server stops
  # def shutdown
  # end
end
