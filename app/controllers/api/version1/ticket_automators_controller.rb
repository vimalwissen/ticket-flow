module Api
  module Version1
    class TicketAutomatorsController < ApplicationController
      before_action :set_workflow, except: [:create]

      # POST /ticket_automators
      def create
        @workflow = Workflow.new(workflow_params)
        
        # Set defaults if not provided (matching user example)
        @workflow.status ||= 2 # Draft
        @workflow.module_id ||= 1 # Tickets
        
        if @workflow.save
          render json: {
            status: true,
            item: {
              id: @workflow.id,
              name: @workflow.name,
              module_id: @workflow.module_id,
              workspace_id: @workflow.workspace_id,
              status: @workflow.status
            }
          }, status: :created
        else
          render json: { errors: @workflow.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /ticket_automators/:id/event
      def create_event
        # Payload: label=...&wf_node=1&data={...}&c=1&r=1
        
        # 1. Create/Find WorkflowEvent
        # Assuming one main event per workflow for now (or finding by context).
        # In this simplistic version, we'll assume we are creating the connection for the Workflow.
        
        # Parse Data JSON
        node_data = JSON.parse(params[:data]) rescue {}

        ActiveRecord::Base.transaction do
          # Create Event Container
          @event = @workflow.events.create!(
            event_type: "ticket_created", # logic to derive this from data usually
            label: params[:label],
            flow: {} # Start empty
          )

          # Create Trigger Node (ID 1)
          @node = @event.nodes.create!(
            wf_node_id: params[:wf_node],
            label: params[:label],
            data: node_data
          )
          
          # Update Coordinate Config (additional_config)
          update_coordinates(params[:wf_node], params[:c], params[:r])
        end

        render json: event_response(@event, @node)
      end

      # PUT /ticket_automators/:id/node
      def create_node
        # Payload: label=...&wf_node=...&data={...}&prev_node[id]=...
        
        node_data = JSON.parse(params[:data]) rescue {}
        prev_node_id = params[:prev_node][:id]
        condition_result = params[:prev_node][:condition] # "1" or "0" if prev was Condition

        ActiveRecord::Base.transaction do
          # Find the main event (Assuming single event chain for this ID)
          @event = @workflow.events.last 

          # Create the Node
          @node = @event.nodes.create!(
            wf_node_id: params[:wf_node],
            label: params[:label],
            data: node_data
          )

          # Update the Flow Graph (Adjacency List)
          update_flow_graph(prev_node_id, condition_result, params[:wf_node])

          # Update Coordinates
          update_coordinates(params[:wf_node], params[:c], params[:r])
        end

        render json: node_response(@event, @node)
      end

      # PUT /ticket_automators/:id/publish
      def publish
        @workflow.update!(status: 1)
        
        render json: {
          status: true,
          token: Time.current.to_i, # Mock token
          item: @workflow.as_json.merge(
            additional_config: @workflow.additional_config,
            api_name: @workflow.name.parameterize.underscore
          )
        }
      end

      private

      def set_workflow
        @workflow = Workflow.find(params[:id])
      end

      def workflow_params
        params.permit(:name, :description, :module_id, :workspace_id, :workflow_type)
      end

      def update_coordinates(node_id, col, row)
        conf = @workflow.additional_config || {}
        conf[node_id.to_s] = { "c" => col, "r" => row }
        @workflow.update!(additional_config: conf)
      end

      def update_flow_graph(prev_id, condition_val, new_id)
        # flow structure: { "1" => 20001, "20001" => { "1" => 30001 } }
        graph = @event.flow || {}
        
        if condition_val.present?
          # Branching: Prev Node -> Condition -> New Node
          # Ensure sub-hash exists
          graph[prev_id.to_s] ||= {} 
          
          # If it was an integer (direct link) convert to hash? 
          # (Scenario: changing generic link to conditional? Unlikely if prev is Condition node)
          if graph[prev_id.to_s].is_a?(Integer)
             # This shouldn't happen if prev node is truly a condition, but safety check:
             graph[prev_id.to_s] = { "1" => graph[prev_id.to_s] }
          end

          graph[prev_id.to_s][condition_val.to_s] = new_id.to_i
        else
          # Direct Link: Prev Node -> New Node
          graph[prev_id.to_s] = new_id.to_i
        end

        @event.update!(flow: graph)
      end

      def event_response(event, node)
        {
          status: true,
          token: Time.current.to_i,
          item: {
            id: event.id,
            workflow_id: @workflow.id,
            wf_node: node.wf_node_id,
            label: event.label,
            data: node.data,
            flow: event.flow,
            additional_config: nil,
            workspace_id: @workflow.workspace_id
          }
        }
      end

      def node_response(event, node)
        {
          status: true,
          token: Time.current.to_i,
          item: {
            id: node.id,
            wf_event_id: event.id,
            label: node.label,
            wf_node: node.wf_node_id,
            subflow_def_id: nil,
            workflow_id: @workflow.id,
            data: node.data,
            additional_config: nil
          }
        }
      end
    end
  end
end
