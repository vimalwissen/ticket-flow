class Api::Version1::AttachmentsController < ApplicationController
  before_action :set_ticket
  before_action :check_attachment_presence, only: [:destroy]

  # POST /api/version1/tickets/:ticket_id/attachment
  def create
    unless params[:attachment].present?
      return render json: { error: "Attachment missing" }, status: :bad_request
    end

    # If replacing existing file — remove old attachment first (optional behaviour)
    @ticket.attachment.purge if @ticket.attachment.attached?

    # Attach new file (this creates an in-memory blob; may not have id yet)
    @ticket.attachment.attach(params[:attachment])

    # Validate first — model validations will add errors if any (size/type)
    if @ticket.valid?
      # Save persists blob association and ticket
      if @ticket.save
        render json: { message: "Attachment uploaded successfully" }, status: :created
      else
        # Rare: save failed for other reasons — cleanup the newly attached blob
        @ticket.attachment.purge if @ticket.attachment.attached?
        render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
      end
    else
      # Validation failed (e.g. size/type). Purge newly attached blob to avoid orphan blob.
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
    if @ticket.attachment.attached?
      @ticket.attachment.purge
      render json: { message: "Attachment removed successfully" }, status: :ok
    else
      render json: { error: "No attachment to remove" }, status: :not_found
    end
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
