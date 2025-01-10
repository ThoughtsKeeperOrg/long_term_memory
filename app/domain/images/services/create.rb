# frozen_string_literal: true

module Images
  module Services
    class Create
      def initialize(params)
        @params = params
      end

      attr_accessor :params, :entity

      def call
        ActiveRecord::Base.transaction do
          create_entity

          return result if result[:errors].present?

          process_file
        end

        result
      end

      private

      def result
        @result ||= { errors: [], entity: nil }
      end

      def create_entity
        @entity = Image.create(thought: params[:thought])

        result[:errors] = entity.errors.full_messages if entity.errors.any?
      end

      def filename
        @filename ||= ActiveStorage::Filename.new(params[:file][:filename]).sanitized
      end

      def attach_file_to_entity(file)
        entity.file.attach(io: File.open(file.path),
                           content_type: params[:file][:type],
                           filename: filename)
      end

      def decoded_base64_content
        Base64.decode64(params[:file][:file_base64])
      end

      def process_file
        file = Tempfile.new(filename, binmode: true)
        begin
          file.write(decoded_base64_content)
          file.rewind
          attach_file_to_entity(file)

          publish_image_event if file_ocr_required?

          result[:entity] = entity
        rescue StandardError => e
          result[:errors].push(e.message)

          raise ActiveRecord::Rollback
        ensure
          file.close
          file.unlink
        end
      end

      def publish_image_event
        # TODO: run in background
        Karafka.producer
               .produce_sync(key: entity.id.to_s,
                             topic: :textimage_created,
                             payload: { file_path: entity.path,
                                        filename: params[:file][:filename] }.to_json)
      end

      def file_ocr_required?
        ActiveModel::Type::Boolean.new.cast(params[:file][:convert_to_text])
      end
    end
  end
end
