class AttachmentsController < ApplicationController
  def create
    ticket = Ticket.find(params[:ticket_id])

    # Replace previous attachment if exists
    ticket.attachment.purge if ticket.attachment.attached?

    ticket.attachment.attach(params[:attachment])

    if ticket.save
      render json: { message: "Attachment uploaded", ticket_id: ticket.id }, status: :created
    else
      render json: { errors: ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end
end