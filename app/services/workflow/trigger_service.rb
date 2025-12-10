class Workflow
  class TriggerService
    def self.call(event_name, context)
      # Find active workflows for this event
      # Assuming event_type string match. 
      # Simplification: Fetch all active workflows and check first event
      
      Workflow.active.find_each do |wf|
        start_event = wf.events.find_by(event_type: event_name)
        if start_event
          puts "Triggering Workflow #{wf.id} for event #{event_name}"
          Workflow::Processor.new.execute(start_event, context)
        end
      end
    end
  end
end
