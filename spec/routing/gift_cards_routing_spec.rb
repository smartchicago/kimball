require 'rails_helper'

RSpec.describe GiftCardsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/gift_cards').to route_to('gift_cards#index')
    end

    it 'routes to #new' do
      expect(get: '/gift_cards/new').to route_to('gift_cards#new')
    end

    it 'routes to #show' do
      expect(get: '/gift_cards/1').to route_to('gift_cards#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/gift_cards/1/edit').to route_to('gift_cards#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/gift_cards').to route_to('gift_cards#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/gift_cards/1').to route_to('gift_cards#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/gift_cards/1').to route_to('gift_cards#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/gift_cards/1').to route_to('gift_cards#destroy', id: '1')
    end
  end
end
