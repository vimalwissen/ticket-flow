module Api
  module Version1
    class WorkflowsController < ApplicationController
      before_action :set_workflow, only: [:show, :update, :destroy]

      # GET /api/version1/workflows
      def index
        @workflows = Workflow.all.order(created_at: :desc)
        render json: @workflows.map { |w| WorkflowSerializer.new(w).as_json }
      end

      # GET /api/version1/workflows/:id
      def show
        render json: WorkflowSerializer.new(@workflow).as_json
      end

      # POST /api/version1/workflows
      def create
        @workflow = Workflow.new
        persister = WorkflowPersister.new(@workflow, workflow_params)

        if persister.persist
          render json: WorkflowSerializer.new(@workflow).as_json, status: :created
        else
          render json: { errors: @workflow.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PUT/PATCH /api/version1/workflows/:id
      def update
        persister = WorkflowPersister.new(@workflow, workflow_params)

        if persister.persist
          render json: WorkflowSerializer.new(@workflow).as_json
        else
          render json: { errors: @workflow.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/version1/workflows/:id
      def destroy
        @workflow.destroy
        head :no_content
      end

      private

      def set_workflow
        @workflow = Workflow.find(params[:id])
      end

      def workflow_params
        # Allow the full nested structure including arbitrary JSON for nodes/data
        params.permit!.slice(:name, :description, :module_id, :workspace_id, :status, :positions, :events)
      end
    end
  end
end
