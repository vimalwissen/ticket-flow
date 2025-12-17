# lib/verify_workflow.rb
# usage: rails runner lib/verify_workflow.rb

puts "\n--- Starting Generic Workflow Verification ---"

# 1. Clean Slate
puts "Cleaning DB..."
Workflow.destroy_all
Ticket.destroy_all
User.destroy_all
puts "DB Cleaned."

# 2. Setup Active Workflow for 'ticket_created'
puts "\n--- Setup: Creating Generic Workflow ---"
wf_create = Workflow.create!(name: "Generic VIP Handler", status: 1)

event_create = wf_create.events.create!(
  event_type: "ticket_created",
  label: "Ticket Created",
  flow: { "1" => 10001, "10001" => { "1" => 20001, "0" => nil }, "20001" => nil }
)

# Nodes with Generic Data Configuration
event_create.nodes.create!(wf_node_id: 1, label: "Start") 

# Condition: Title contains "VIP"
event_create.nodes.create!(
  wf_node_id: 10001, 
  label: "Subject Check",
  data: { 
    field: "title", 
    operator: "contains", 
    value: "VIP" 
  }
) 

# Action: Set Priority to 'high'
event_create.nodes.create!(
  wf_node_id: 20001, 
  label: "Set High Priority",
  data: { 
    field: "priority", 
    action_type: "set", 
    value: "high" 
  }
)

puts "Workflow '#{wf_create.name}' created."
puts "Nodes Configured:"
event_create.nodes.each do |n|
  puts "  ID: #{n.wf_node_id} Type: #{n.node_type} Data: #{n.data}"
end

# 3. Setup Users
user = User.create!(email: "customer@example.com", name: "Customer", password: "password")
agent = User.create!(email: "agent@example.com", name: "Agent", password: "password")

# 4. Test Case 1: Matching Ticket (VIP)
puts "\n--- Test Case 1: Creating VIP Ticket (Should Trigger) ---"
ticket_vip = Ticket.create!(
  title: "Urgent VIP Request",
  description: "Help me",
  requestor: user.email,
  assign_to: agent.email,
  status: "open",
  priority: "low", 
  source: "email"
)

# Reload to check changes
ticket_vip.reload
if ticket_vip.priority == "high"
  puts "SUCCESS: VIP Ticket priority updated to 'high'."
else
  puts "FAILURE: VIP Ticket priority is '#{ticket_vip.priority}', expected 'high'."
end

# 5. Test Case 2: Non-Matching Ticket
puts "\n--- Test Case 2: Creating Regular Ticket (Should Not Change Priority) ---"
ticket_reg = Ticket.create!(
  title: "Normal Request",
  description: "Help me",
  requestor: user.email,
  assign_to: agent.email,
  status: "open",
  priority: "low",
  source: "web"
)

ticket_reg.reload
if ticket_reg.priority == "low"
  puts "SUCCESS: Regular Ticket priority remained 'low'."
else
  puts "FAILURE: Regular Ticket priority changed to '#{ticket_reg.priority}'."
end

puts "\n--- Verification Completed ---"
