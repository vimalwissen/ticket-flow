class CommentsController < ApplicationController

  # POST /add_comment/:ticket_id
  def create_comment
    ticket = Ticket.find_by(id: params[:ticket_id])

    if ticket.nil?
      return render json: { error: "Ticket not found" }, status: :not_found
    end

    comment = Comment.new(
      ticket_id: ticket.id,
      content: params[:content],
      author: params[:author]
    )

    if comment.save
      render json: {
        message: "Comment added successfully",
        comment: comment
      }, status: :created
    else
      render json: {
        error: comment.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
end