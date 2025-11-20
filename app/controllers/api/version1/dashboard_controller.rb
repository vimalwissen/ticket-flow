class Api::Version1::DashboardController < ApplicationController

  def summary
    render json: {
      data: {
        type: "dashboard_summary",
        id: "main",
        attributes: {
          overdue: Ticket.overdue.count,
          due_today: Ticket.due_today.count,
          open: Ticket.open_tickets.count,
          unassigned: Ticket.unassigned.count
        }
      }
    }
  end

end
