# frozen_string_literal: true

module Api
  class ThoughtsController < Api::BaseController
    def index
      @items = Thought.all

      render json: @items
    end

    def show
      render json: Thought.find(params[:id])
    end

    def create
      result = Thoughts::Services::Create.new(thought_params).call

      render json: result, status: result[:errors].present? ? 400 : 201
    end

    def thought_params
      params.permit(thought: [:content],
                    file: %i[filename type convert_to_text file_base64])
    end
  end
end
