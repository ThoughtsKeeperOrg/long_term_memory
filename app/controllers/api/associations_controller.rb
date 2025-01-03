# frozen_string_literal: true

module Api
  class AssociationsController < Api::BaseController
    def show
      render json: Thoughts::Services::GetAssociated.new.call(params[:id])[:items]
    end
  end
end
