class Api::ThoughtsController < Api::BaseController
  def index
    @items = Thought.all

    render json: @items
  end

  def create
    # TODO: extract to service object, wrap in transaction
    @thought = Thought.create(thought_params)

    if @thought.errors.any?
      render json: @thought.errors.full_messages, status: 400
    else
      if params[:file]
        image = Image.create(thought: @thought)
        file = Tempfile.new(params[:file][:filename], binmode: true)
        begin
          decode_base64_content = Base64.decode64(params[:file][:file_base64])
          file.write(decode_base64_content)
          file.rewind
          image.file.attach(io: file, filename: params[:file][:filename], content_type: params[:file][:type])
        ensure
           file.close
           file.unlink
        end
      end

      render json: @thought, status: 201
    end
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
