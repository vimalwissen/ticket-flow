class Api::Version1::DashboardController < ApplicationController
  # GET /api/version1/dashboard/summary
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

  # GET /api/version1/dashboard/charts
  def charts
    render json: {
      data: {
        type: "dashboard_charts",
        id: "main",
        attributes: {
          priority_split: Ticket.priority_split,
          status_distribution: Ticket.status_distribution,
          new_tickets_last_30_days: Ticket.new_last_30_days
        }
      }
    }
  end

end
