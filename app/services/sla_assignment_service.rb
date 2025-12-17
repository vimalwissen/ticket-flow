class SlaAssignmentService
  def self.apply(ticket)
    new(ticket).apply
  end

  def initialize(ticket)
    @ticket = ticket
  end

  def apply
    policy = SlaPolicy.find_by(priority: @ticket.priority)

    return unless policy

    now = Time.current

    @ticket.update!(
      sla_policy_id: policy.id,
      target_first_response_at: now + policy.first_response_minutes.minutes,
      target_resolution_at:     now + policy.resolution_minutes.minutes
    )
  end
end
