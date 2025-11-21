class Api::Version1::DashboardController < ApplicationController
  # GET /api/version1/dashboard/summary
  def summary
    render json: { metrics: DashboardMetricsService.call }
  end

  # GET /api/version1/dashboard/charts
  def charts
    render json: { charts: DashboardChartsService.call }
  end


end
