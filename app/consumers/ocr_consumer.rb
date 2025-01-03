# frozen_string_literal: true

# Example consumer that prints messages payloads
class OcrConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      # Rails.logger.debug message.payload
      # if message.payload['status'] == 'scanned'
      process_message(message)
    # else
    #   # TODO
    # end
    rescue StandardError => e
      p '*' * 88
      p 'Message consuption error:'
      p e.message
      p e.backtrace.join("\n")
      p '*' * 88
    end
  end

  def process_message(message)
    thought = Image.find(message.key).thought
    thought.content = [thought.content, message.payload['text']].join("\n")
    thought.save

    Karafka.producer
           .produce_sync(key: thought.id.to_s,
                         topic: :entities_updates,
                         payload: { entitity_type: :thought,
                                    entity: thought,
                                    status: :updated,
                                    user_id: 'placeholder-user_id' }.to_json)
  end
end
