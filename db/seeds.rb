# This file should ensure the existence of records required to run the application in every environment
# (production, development, test). The code here should be idempotent so that it can be executed
# at any point in every environment. The data can then be loaded with:
#   bin/rails db:seed
# or created alongside the database with:
#   bin/rails db:setup

puts "Seeding Users..."

User.find_or_create_by!(email: "admin@gmail.com") do |u|
  u.name     = "Admin User"
  u.password = "password123"
  u.role     = "admin"
end

User.find_or_create_by!(email: "agent@gmail.com") do |u|
  u.name     = "Support Agent"
  u.password = "password123"
  u.role     = "agent"
end

User.find_or_create_by!(email: "consumer1@gmail.com") do |u|
  u.name     = "Customer One"
  u.password = "password123"
  u.role     = "consumer"
end

User.find_or_create_by!(email: "consumer2@gmail.com") do |u|
  u.name     = "Customer Two"
  u.password = "password123"
  u.role     = "consumer"
end

puts "Users seeded: #{User.count}"


puts "Seeding Tickets..."

Ticket.find_or_create_by!(ticket_id: "1") do |t|
  t.title       = "Title1"
  t.source      = "phone"
  t.status      = "resolved"
  t.priority    = "low"
  t.description = "logging issue"
  t.requestor   = "Person1"
end

Ticket.find_or_create_by!(ticket_id: "2") do |t|
  t.title       = "Title2"
  t.source      = "phone"
  t.status      = "InProgress"
  t.priority    = "high"
  t.description = "payment issue"
  t.requestor   = "Person2"
end

puts "Tickets seeded: #{Ticket.count}"

puts "Done seeding!"
