module Images
  module Services
    class Create
      def initialize(params)
        @params = params
      end

      attr_accessor :params, :entity

      def call
        @entity = Image.create(thought: params[:thought])

        if entity.errors.any?
          result[:errors] = entity.errors.full_messages

          return result
        end

        filename = ActiveStorage::Filename.new(params[:file][:filename]).sanitized
        file = Tempfile.new(filename, binmode: true)
        begin
          decode_base64_content = Base64.decode64(params[:file][:file_base64])
          file.write(decode_base64_content)
          file.rewind
          entity.file.attach(io: File.open(file.path),
                             content_type: params[:file][:type],
                             filename: filename)

          publish_image_event if file_ocr_required?
          result[:entity] = entity
        ensure
           file.close
           file.unlink
        end

        result
      end

      private

      def result
        @result ||= { errors: [], entity: nil }
      end

      def publish_image_event
        Karafka.producer
               .produce_sync(key: entity.id.to_s,
                             topic: "text_image.created",
                             payload: { file_path: entity.path,
                                        filename: params[:file][:filename] }.to_json)
      end

      def file_ocr_required?
        ActiveModel::Type::Boolean.new.cast(params[:file][:convert_to_text])
      end
    end
  end
end
