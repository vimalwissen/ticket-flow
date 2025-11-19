module Api
    module Version1
        class TicketsController < ApplicationController

            # GET /tickets
            def index
            tickets = Ticket.all
            render json: tickets
            end

            
        end
    end
end