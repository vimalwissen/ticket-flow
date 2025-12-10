# lib/verify_workflow.rb
# usage: rails runner lib/verify_workflow.rb

puts "--- Starting Verification ---"

# 1. Setup Data
Workflow.destroy_all
wf = Workflow.create!(name: "Test Automation", status: 1)
puts "Created Workflow: #{wf.id}"

event = wf.events.create!(
  event_type: "ticket_created", 
  label: "Ticket is raised", 
  flow: { "1" => 20001, "20001" => { "1" => 40001 } }
)
puts "Created Event: #{event.id}"

# Nodes
# Note: wf_node_id determines type via range
# 1 -> Event
# 20001 -> Action (Subject Check)
# 40001 -> Orchestration (Set Priority)

node1 = event.nodes.create!(wf_node_id: 1, label: "Ticket is raised")
node2 = event.nodes.create!(wf_node_id: 20001, label: "Subject contains VIP") 
node3 = event.nodes.create!(wf_node_id: 40001, label: "Set Priority High")

puts "Nodes created: #{event.nodes.count}"
puts "Node Types: #{event.nodes.map { |n| "#{n.wf_node_id}:#{n.node_type}" }.join(', ')}"

# 2. Mock Context (Ticket)
class MockTicket
  attr_accessor :subject, :priority, :saved
  
  def initialize(subject)
    @subject = subject
    @priority = 1
    @saved = false
  end

  def save
    @saved = true
    puts "MOCK TICKET SAVED: Priority is now #{@priority}"
  end
end

# 3. Trigger for VIP Ticket
ticket_vip = MockTicket.new("Issue from VIP customer")
puts "\n--- Triggering for VIP Ticket ---"
Workflow::TriggerService.call("ticket_created", ticket_vip)

if ticket_vip.priority == 4
  puts "SUCCESS: VIP Ticket priority updated to 4"
else
  puts "FAILURE: VIP Ticket priority is #{ticket_vip.priority}"
end

# 4. Trigger for Non-VIP Ticket
ticket_norm = MockTicket.new("Issue from regular customer")
puts "\n--- Triggering for Regular Ticket ---"
Workflow::TriggerService.call("ticket_created", ticket_norm)

if ticket_norm.priority == 1
  puts "SUCCESS: Regular Ticket priority remained 1"
else
  puts "FAILURE: Regular Ticket priority is #{ticket_norm.priority}"
end
