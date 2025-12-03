class Api::Version1::AttachmentsController < ApplicationController
  def create
    ticket = Ticket.find(params[:ticket_id])

    ticket.attachment.purge if ticket.attachment.attached?

    ticket.attachment.attach(params[:attachment])

    if ticket.save
      render json: { message: "Attachment uploaded" }, status: :created
    else
      render json: { errors: ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end
end