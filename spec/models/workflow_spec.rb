require 'rails_helper'

RSpec.describe Workflow, type: :model do
  describe 'validations' do
    it 'requires a name' do
      workflow = Workflow.new(name: nil)
      expect(workflow).not_to be_valid
      expect(workflow.errors[:name]).to include("can't be blank")
    end

    it 'is valid with a name' do
      workflow = Workflow.new(name: 'Test Workflow')
      expect(workflow).to be_valid
    end
  end

  describe 'associations' do
    it 'has many events' do
      association = described_class.reflect_on_association(:events)
      expect(association.macro).to eq :has_many
    end

    it 'destroys events when destroyed' do
      workflow = Workflow.create!(name: 'Test')
      workflow.events.create!(event_type: 'ticket_created', label: 'Start')
      
      expect { workflow.destroy }.to change(WorkflowEvent, :count).by(-1)
    end
  end

  describe 'status' do
    it 'defaults to draft (2)' do
      workflow = Workflow.create!(name: 'Test')
      expect(workflow.status).to eq(2)
    end

    it 'can be set to active (1)' do
      workflow = Workflow.create!(name: 'Test', status: 1)
      expect(workflow.status).to eq(1)
    end
  end

  describe 'scopes' do
    it 'finds active workflows' do
      active = Workflow.create!(name: 'Active', status: 1)
      draft = Workflow.create!(name: 'Draft', status: 2)
      
      expect(Workflow.where(status: 1)).to include(active)
      expect(Workflow.where(status: 1)).not_to include(draft)
    end
  end
end
