module Thoughts
  module Services
    class Create
      def initialize(params)
        @params = params
      end

      attr_accessor :params, :entity

      def call
        ActiveRecord::Base.transaction do
          @entity = Thought.create(params[:thought])

          if entity.errors.any?
            result[:errors] = entity.errors.full_messages
          else
            if params[:file]
              save_image
              raise ActiveRecord::Rollback if result[:errors].present?
            end
            result[:entity] = entity
          end
        end

        result
      end

      private

      def result
        @result ||= { errors: [], entity: nil }
      end

      def save_image
        image_result = Images::Services::Create.new({ thought: entity, file: params[:file] }).call

        if image_result[:errors].present?
          result[:errors] += image_result[:errors]
        end
      end
    end
  end
end
