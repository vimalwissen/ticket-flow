class Api::Version1::AttachmentsController < ApplicationController
  before_action :set_ticket
  before_action :check_attachment_presence, only: [:show, :destroy]

  # POST /api/version1/tickets/:ticket_id/attachment
  def create
    uploaded_file = params[:attachment]

    return render json: { error: "Attachment missing" }, status: :bad_request unless uploaded_file.present?

    # --- VALIDATE SIZE BEFORE ATTACHING ---
    if uploaded_file.size > 10.megabytes
      return render json: { error: "File size must be less than 10 MB" }, status: :unprocessable_entity
    end

    # --- VALIDATE ALLOWED TYPES ---
    allowed = [
      "application/pdf",
      "application/msword",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      "application/x-msdownload",
      "application/vnd.microsoft.portable-executable"
    ]

    unless allowed.include?(uploaded_file.content_type)
      return render json: { error: "File must be PDF / DOC / DOCX / EXE" }, status: :unprocessable_entity
    end

    # Remove old attachment if exists
    @ticket.attachment.purge if @ticket.attachment.attached?

    # --- SAFE ATTACHMENT ---
    @ticket.attachment.attach(uploaded_file)

    if @ticket.save
      render json: { message: "Attachment uploaded successfully" }, status: :created
    else
      # Safety: ensure no invalid blob stays attached
      @ticket.attachment.purge if @ticket.attachment.attached?
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
    @ticket = Ticket.find_by!(ticket_id: params[:ticket_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Ticket not found" }, status: :not_found
  end

  def check_attachment_presence
    unless @ticket.attachment.attached?
      render json: { error: "No attachment found for this ticket" }, status: :not_found
    end
  end
end
