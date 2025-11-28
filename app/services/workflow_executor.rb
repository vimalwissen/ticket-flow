class WorkflowExecutor
  # Evaluates workflows for a given event and subject (e.g., a Ticket instance)
  def initialize(event:, subject:, context: {})
    @event = event.to_s
    @subject = subject
    @context = context
  end

  def run
    Workflow.active.where(event: @event).find_each do |workflow|
      next unless evaluate_conditions(workflow)

      execute_actions(workflow)
    end
  end

  private

  def evaluate_conditions(workflow)
    conds = (workflow.conditions || {})["all"] || []
    return true if conds.empty?

    conds.all? { |c| evaluate_condition(c) }
  end

  def evaluate_condition(cond)
    field = cond["field"]
    operator = cond["operator"]
    value = cond["value"]

    subject_value = dig_subject(field)

    case operator
    when "present"
      !!subject_value
    when "blank"
      !subject_value
    when "equals"
      subject_value.to_s == value.to_s
    when "not_equals"
      subject_value.to_s != value.to_s
    else
      false
    end
  end

  def dig_subject(field)
    if field.to_s.include?('.')
      parts = field.split('.')
      parts.reduce(@subject) do |obj, part|
        break nil unless obj
        if obj.respond_to?(part)
          obj.public_send(part)
        elsif obj.is_a?(Hash)
          obj[part]
        else
          nil
        end
      end
    else
      if @subject.respond_to?(field)
        @subject.public_send(field)
      elsif @subject.is_a?(Hash)
        @subject[field]
      else
        nil
      end
    end
  end

  def execute_actions(workflow)
    (workflow.actions || []).each do |action|
      execute_action(action)
    end
  end

  def execute_action(action)
    type = action["type"]
    case type
    when "update"
      field = action["field"]
      value = action["value"]
      apply_update(field, value)
    when "assign"
      user_id = action["user_id"]
      apply_update("assigned_to_id", user_id)
    else
      Rails.logger.warn("Unknown workflow action: #{type}")
    end
  end

  def apply_update(field, value)
    if @subject.respond_to?(:update)
      @subject.update(field => value)
    else
      if @subject.respond_to?(:[]=)
        @subject[field] = value
      end
    end
  end
end
