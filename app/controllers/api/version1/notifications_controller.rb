module Api
  module Version1
    class NotificationsController < ApplicationController
      before_action :authenticate_request

      # /api/version1/notifications
      def index
        notifications = NotificationService.recent_for(current_user)
        render json: notifications.map { |n| serialize(n) }
      end

      # /api/version1/notifications/mark_read
      def mark_read
        notification = current_user.notifications.find(params[:id])
        NotificationService.mark_read(notification)
        render json: { success: true }
      end

      # /api/version1/notifications/mark_all_read
      def mark_all_read
        NotificationService.mark_all_read(current_user)
        render json: { success: true }
      end

      private

      def serialize(n)
        {
          id: n.id,
          message: n.message,
          read: n.read_at.present?,
          created_at: n.created_at,
          notifiable_id: n.notifiable_id,
          notifiable_type: n.notifiable_type
        }
      end
    end
  end
end
