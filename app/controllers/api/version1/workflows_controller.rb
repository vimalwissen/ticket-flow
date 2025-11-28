module Api
  module Version1
    class WorkflowsController < ApplicationController
      # Basic controller to create and list workflows
      def index
        workflows = Workflow.all
        render json: workflows
      end

      def create
        workflow = Workflow.new(workflow_params)
        if workflow.save
          render json: workflow, status: :created
        else
          render json: { errors: workflow.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def workflow_params
        params.require(:workflow).permit(:name, :event, :active, conditions: {}, actions: [])
      end
    end
  end
end
