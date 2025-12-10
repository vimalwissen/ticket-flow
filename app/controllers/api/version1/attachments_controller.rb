class Api::Version1::AttachmentsController < ApplicationController
  before_action :set_ticket
  before_action :check_attachment_presence, only: [:show, :destroy]

  # POST /api/version1/tickets/:ticket_id/attachment
  def create
    return render json: { error: "Attachment missing" }, status: :bad_request unless params[:attachment].present?

    # Remove old attachment if exists
    @ticket.attachment.purge if @ticket.attachment.attached?

    # Attach new file
    @ticket.attachment.attach(params[:attachment])

    if @ticket.save
      render json: { message: "Attachment uploaded successfully" }, status: :created
    else
      render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /api/version1/tickets/:ticket_id/attachment
  def show
    attachment = @ticket.attachment

    render json: {
      filename: attachment.filename.to_s,
      content_type: attachment.content_type,
      byte_size: attachment.byte_size,
      url: url_for(attachment),
      created_at: attachment.created_at
    }, status: :ok
  end

  # DELETE /api/version1/tickets/:ticket_id/attachment
  def destroy
    @ticket.attachment.purge
    render json: { message: "Attachment removed successfully" }, status: :ok
  end

  private

  def set_ticket
    @ticket = Ticket.find_by(ticket_id: params[:ticket_id])
    return render json: { error: "Ticket not found" }, status: :not_found unless @ticket
  end

  def check_attachment_presence
    unless @ticket.attachment.attached?
      render json: { error: "No attachment found for this ticket" }, status: :not_found
    end
  end
end
