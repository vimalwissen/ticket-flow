module Api
  module Version1
    class WorkflowsController < ApplicationController
      before_action :set_workflow, only: [:show, :update, :destroy]

      # GET /api/version1/workflows
      def index
        @workflows = Workflow.all.order(created_at: :desc)
        render json: structured_json(@workflows)
      end

      # GET /api/version1/workflows/:id
      def show
        render json: single_workflow_json(@workflow)
      end

      # POST /api/version1/workflows
      def create
        @workflow = Workflow.new(workflow_params)

        if @workflow.save
          render json: single_workflow_json(@workflow), status: :created
        else
          render json: { errors: @workflow.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PUT/PATCH /api/version1/workflows/:id
      def update
        if @workflow.update(workflow_params)
          render json: single_workflow_json(@workflow)
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
        params.require(:workflow).permit(
          :name, :description, :status, :module_id, :workspace_id, :workflow_type,
          additional_config: {},
          events_attributes: [
            :id, :label, :event_type, :flow, :_destroy,
            nodes_attributes: [
              :id, :wf_node_id, :label, :node_type, :data, :_destroy
            ]
          ]
        )
      end

      def structured_json(workflows)
        workflows.map { |w| single_workflow_json(w) }
      end

      def single_workflow_json(workflow)
        {
          id: workflow.id,
          name: workflow.name,
          description: workflow.description,
          status: workflow.status,
          module_id: workflow.module_id,
          workspace_id: workflow.workspace_id,
          additional_config: workflow.additional_config,
          created_at: workflow.created_at,
          events: workflow.events.map { |e|
            {
              id: e.id,
              event_type: e.event_type,
              label: e.label,
              flow: e.flow,
              nodes: e.nodes.map { |n|
                {
                  id: n.id,
                  wf_node_id: n.wf_node_id,
                  label: n.label,
                  node_type: n.node_type,
                  data: n.data
                }
              }
            }
          }
        }
      end
    end
  end
end
