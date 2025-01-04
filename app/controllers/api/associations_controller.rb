# frozen_string_literal: true

module Api
  class AssociationsController < Api::BaseController
    def index
      render json: Thoughts::Services::GetAssociated.new.call(params[:thought_id])[:items]
    end
  end
end
