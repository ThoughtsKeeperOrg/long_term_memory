# frozen_string_literal: true

module Thoughts
  module Services
    class Create
      def initialize(params)
        @params = params
      end

      attr_accessor :params, :entity

      def call
        ActiveRecord::Base.transaction do
          create_entity

          if result[:errors].blank?
            save_image if params[:file]
            result[:entity] = entity
          end
        end

        result
      end

      private

      def result
        @result ||= { errors: [], entity: nil }
      end

      def create_entity
        @entity = Thought.create(params[:thought])

        result[:errors] = entity.errors.full_messages if entity.errors.any?
      end

      def save_image
        image_result = Images::Services::Create.new({ thought: entity, file: params[:file] }).call

        return if image_result[:errors].blank?

        result[:errors] += image_result[:errors]

        raise ActiveRecord::Rollback if result[:errors].present?
      end
    end
  end
end
