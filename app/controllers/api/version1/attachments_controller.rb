class Api::Version1::AttachmentsController < ApplicationController
  before_action :set_ticket
  before_action :check_attachment_presence, only: [:destroy]

  # POST /api/version1/tickets/:ticket_id/attachment
  def create
    unless params[:attachment].present?
      return render json: { error: "Attachment missing" }, status: :bad_request
    end

    # Reject if attachment already exists
    if @ticket.attachment.attached?
      return render json: { error: "Attachment already exists. Please delete the existing attachment first." }, status: :conflict
    end

    # Attach new file
    @ticket.attachment.attach(params[:attachment])

    # Validate the attachment
    if @ticket.valid?
      if @ticket.save
        render json: { message: "Attachment uploaded successfully" }, status: :created
      else
        @ticket.attachment.purge if @ticket.attachment.attached?
        render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
      end
    else
      @ticket.attachment.purge if @ticket.attachment.attached?
      render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /api/version1/tickets/:ticket_id/attachment
  def show
    unless @ticket.attachment.attached?
      return render json: {
        message: "No attachment found for this ticket"
      }, status: :ok
    end

    blob = @ticket.attachment.blob

    render json: {
      filename: blob.filename.to_s,
      content_type: blob.content_type,
      byte_size: blob.byte_size,
      created_at: blob.created_at
    }, status: :ok
  end



  # DELETE /api/version1/tickets/:ticket_id/attachment
  def destroy
    if @ticket.attachment.attached?
      @ticket.attachment.purge
      render json: { message: "Attachment removed successfully" }, status: :ok
    else
      render json: { error: "No attachment to remove" }, status: :not_found
    end
  end

  # GET /api/version1/tickets/:ticket_id/attachment/download
  def download
    unless @ticket.attachment.attached?
      return render json: { error: "No attachment found for this ticket" }, status: :not_found
    end

    blob = @ticket.attachment.blob
    send_data blob.download,
              filename: blob.filename.to_s,
              type: blob.content_type,
              disposition: "attachment"
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
