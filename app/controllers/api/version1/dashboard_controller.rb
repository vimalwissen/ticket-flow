class Api::Version1::DashboardController < ApplicationController
  before_action only: [:summary, :charts] do
    authorize_role("admin", "agent")
  end
 
  # GET /api/version1/dashboard/summary
  def summary
    render json: { metrics: DashboardMetricsService.call }
  end
 
  # GET /api/version1/dashboard/charts
  def charts
    render json: { charts: DashboardChartsService.call }
  end
end