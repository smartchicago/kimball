require 'rails_helper'

RSpec.describe CalendarController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  let!(:event_invitation) { FactoryGirl.create(:event_invitation, created_by: user.id) }
  let!(:event) {
    # hacky. event is where the user lives.
    event_invitation.event.user_id = user.id
    event_invitation.event.save
    event_invitation.event
  }
  let!(:person) { event_invitation.invitees.sample }
  let!(:time_slot) { event_invitation.event.time_slots.sample }
  let!(:reservation) { V2::Reservation.create(person: person, time_slot: time_slot) }

  describe 'admin user logged in' do
    before(:each) do
      sign_in :user, user # sign_in(scope, resource)
    end

    describe 'GET #show' do
      subject { get :show }
      it 'renders the calendar' do
        get :show
        expect(response.status).to eq(200)
        expect(response).to render_template('calendar/show')
      end
    end
  end

  describe 'Person getting ical feed' do
    before(:each) do
      # foo to convince devise to allow us unauthenticated visitors
      allow(controller).to receive(:authenticate_user!).and_return(true)
      allow(controller).to receive(:current_user).and_return(nil)
      person.reload
      user.reload
      reservation.reload
    end

    it 'provides the feed to good person tokens' do
      get :feed, token: person.token
      expect(response.status).to eq(200)
      expect(response.body).to have_text(reservation.description)
    end

    it 'provides the ical feed to good user tokens' do
      # the user created above doesn't have a reservation.
      reservation.reload
      get :feed, token: reservation.user.token
      expect(response.status).to eq(200)
      expect(response.body).to have_text(reservation.description)
    end

    it 'redirects for no token' do
      get :feed
      expect(response.status).to eq(302)
      expect(response).to redirect_to(root_url)
    end

    it 'redirects for incorrect tokens' do
      get :feed, token: 'foobar'
      expect(response.status).to eq(302)
      expect(response).to redirect_to(root_url)
    end
  end
end
