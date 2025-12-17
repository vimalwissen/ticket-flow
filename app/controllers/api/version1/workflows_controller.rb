module Api
  module Version1
    class WorkflowsController < ApplicationController
      before_action :set_workflow, only: [:show, :destroy]

      # GET /api/version1/workflows
      def index
        @workflows = Workflow.all.order(created_at: :desc)
        render json: structured_json(@workflows)
      end

      # GET /api/version1/workflows/:id
      def show
        render json: single_workflow_json(@workflow)
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
