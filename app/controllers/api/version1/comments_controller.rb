class Api::Version1::CommentsController < ApplicationController

  before_action :set_ticket

  # GET /tickets/:ticket_id/comments
  def index
    comments = @ticket.comments.order(created_at: :desc)

    render json: {
      message: "Comments fetched successfully",
      ticket_id: @ticket.ticket_id,
      comments: comments
    }, status: :ok
  end

  # POST /tickets/:ticket_id/comments
  def create
    comment = @ticket.comments.build(comment_params)

    if comment.save
      render json: { message: "Comment added successfully", comment: comment },
             status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /tickets/:ticket_id/comments/:id
  def destroy
    comment = @ticket.comments.find_by(id: params[:id])

    return render json: { error: "Comment not found" }, status: :not_found unless comment

    comment.destroy

    render json: { message: "Comment deleted successfully" }, status: :ok
  end


  private

  def set_ticket
    @ticket = Ticket.find_by(ticket_id: params[:ticket_id])
    render json: { error: "Ticket not found" }, status: :not_found unless @ticket
  end

  def comment_params
    params.permit(:content, :author)
  end
end
