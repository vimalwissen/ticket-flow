class Api::Version1::CommentsController < ApplicationController

  # GET /tickets/:ticket_id/comments
  def index
    ticket = Ticket.find_by(ticket_id: params[:ticket_id])

    return render json: { error: "Ticket not found" }, status: :not_found if ticket.nil?

    comments = ticket.comments.order(created_at: :desc)

    render json: {
      message: "Comments fetched successfully",
      ticket_id: ticket.ticket_id,
      comments: comments
    }, status: :ok
  end


  # POST /tickets/:ticket_id/comments
  def create
    ticket = Ticket.find_by(ticket_id: params[:ticket_id])

    return render json: { error: "Ticket not found" }, status: :not_found if ticket.nil?

    comment = ticket.comments.build(
      content: params[:content],
      author: params[:author]
    )

    if comment.save
      render json: {
        message: "Comment added successfully",
        comment: comment
      }, status: :created
    else
      render json: { error: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
