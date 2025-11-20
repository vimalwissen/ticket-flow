# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
tickets = Ticket.create([
  { 
    ticket_id: "1",
    title: "Title1",
    source: "phone",
    status: "resolved",
    priority: "low",
    description: "logging issue",
    user_name: "Person1",


  }, 
  
  { 
    ticket_id: "2",
    source: "phone",
    title: "Title2",
    status: "in_progress",
    priority: "high",
    description: "payment issue",
    user_name: "Person2",
  }
])