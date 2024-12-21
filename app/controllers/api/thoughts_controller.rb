class Api::ThoughtsController < Api::BaseController
  def index
    @items = Thought.all

    render json: @items
  end

  def create
    result = Thoughts::Services::Create.new({ thought: thought_params, file: params[:file] }).call

    render json: result, status: result[:errors].present? ? 400 : 201
  end

  def update
    @thought = Thought.find(params[:id])
    @thought.attributes = thought_params
    @thought.save
    if @thought.errors.any?
      render json: @thought.errors.full_messages, status: 400
    else
      head 200
    end
  end

  def destroy
    Thought.find(params[:id]).destroy

    head 200
  end

  def thought_params
    params
      .require(:thought)
      .permit(:content)
  end
end
