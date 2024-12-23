# frozen_string_literal: true

module Api
  class ThoughtsController < Api::BaseController
    def index
      @items = Thought.all

      render json: @items
    end

    def create
      result = Thoughts::Services::Create.new(thought_params).call

      render json: result, status: result[:errors].present? ? 400 : 201
    end

    def update
      @thought = Thought.find(params[:id])
      @thought.attributes = thought_params
      @thought.save
      if @thought.errors.any?
        render json: @thought.errors.full_messages, status: :bad_request
      else
        head :ok
      end
    end

    def destroy
      Thought.find(params[:id]).destroy

      head :ok
    end

    def thought_params
      params.permit(thought: [:content],
                    file: %i[filename type convert_to_text file_base64])
    end
  end
end
