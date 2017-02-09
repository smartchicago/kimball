require 'rails_helper'
require 'faker'
require 'support/poltergeist_js_hack_for_login'
require 'capybara/email/rspec'
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe MailchimpUpdatesController, type: :controller do
  login_user

  # This should return the minimal set of attributes required to create a valid
  # MailchimpUpdate. As you add validations to MailchimpUpdate, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { email: Faker::Internet.email, update_type: 'unsubscribe', fired_at: '2016-03-30 13:01:21' } }

  let(:invalid_attributes) { { email: 'bad-email@example.com', update_type: 'none', fired_at: '2016-03-30 13:01:21' } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # MailchimpUpdatesController. Be sure to keep this updated too.
  # let(:valid_session) { controller.stub!(:signed_in?).and_return(true) }

  describe 'GET #index' do
    it 'assigns all mailchimp_updates as @mailchimp_updates' do
      mailchimp_update = MailchimpUpdate.create! valid_attributes
      get :index
      expect(assigns(:mailchimp_updates)).to eq([mailchimp_update])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested mailchimp_update as @mailchimp_update' do
      skip('unknown, routing issue')
      mailchimp_update = MailchimpUpdate.create! valid_attributes
      get :show, params: { id: mailchimp_update.to_param }
      expect(assigns(:mailchimp_update)).to eq(mailchimp_update)
    end
  end

  describe 'GET #new' do
    it 'assigns a new mailchimp_update as @mailchimp_update' do
      get :new
      expect(assigns(:mailchimp_update)).to be_a_new(MailchimpUpdate)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested mailchimp_update as @mailchimp_update' do
      skip('unknown, routing issue')
      mailchimp_update = MailchimpUpdate.create! valid_attributes
      get :edit, params: { id: mailchimp_update.to_param }
      expect(assigns(:mailchimp_update)).to eq(mailchimp_update)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new MailchimpUpdate' do
        expect {
          post :create, params: { mailchimpkey: ENV['MAILCHIMP_WEBHOOK_SECRET_KEY'], data: { email: Faker::Internet.email }, mailchimp_update: valid_attributes }
        }.to change(MailchimpUpdate, :count).by(1)
      end

      it 'assigns a newly created mailchimp_update as @mailchimp_update' do
        post :create, params: { mailchimpkey: ENV['MAILCHIMP_WEBHOOK_SECRET_KEY'], data: { email: Faker::Internet.email }, mailchimp_update: valid_attributes }
        expect(assigns(:mailchimp_update)).to be_a(MailchimpUpdate)
        expect(assigns(:mailchimp_update)).to be_persisted
      end

      it 'redirects to the created mailchimp_update' do
        post :create, params: { mailchimpkey: ENV['MAILCHIMP_WEBHOOK_SECRET_KEY'], data: { email: Faker::Internet.email }, mailchimp_update: valid_attributes }
        expect(response).to redirect_to(MailchimpUpdate.last)
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved mailchimp_update as @mailchimp_update' do
        skip('Will fix invalid tests later')
        post :create, params: { mailchimpkey: ENV['MAILCHIMP_WEBHOOK_SECRET_KEY'], data: { email: Faker::Internet.email }, mailchimp_update: invalid_attributes }
        expect(assigns(:mailchimp_update)).to be_a_new(MailchimpUpdate)
      end

      it "re-renders the 'new' template" do
        skip('Will fix invalid tests later')
        post :create, params: { mailchimpkey: ENV['MAILCHIMP_WEBHOOK_SECRET_KEY'], data: { email: Faker::Internet.email }, mailchimp_update: invalid_attributes }
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes)  { { email: Faker::Internet.email, update_type: 'subscribe', fired_at: '2016-03-30 13:01:21' } }

      it 'updates the requested mailchimp_update' do
        skip('unknown, routing issue')
        mailchimp_update = MailchimpUpdate.create! valid_attributes
        put :update, params: { id: mailchimp_update.to_param, mailchimp_update: new_attributes }
        mailchimp_update.reload
        skip('Add assertions for updated state')
      end

      it 'assigns the requested mailchimp_update as @mailchimp_update' do
        skip('unknown, routing issue')
        mailchimp_update = MailchimpUpdate.create! valid_attributes
        put :update, params: { id: mailchimp_update.to_param, mailchimp_update: valid_attributes }
        expect(assigns(:mailchimp_update)).to eq(mailchimp_update)
      end

      it 'redirects to the mailchimp_update' do
        skip('unknown, routing issue')
        mailchimp_update = MailchimpUpdate.create! valid_attributes
        put :update, params: { id: mailchimp_update.to_param, mailchimp_update: valid_attributes }
        expect(response).to redirect_to(mailchimp_update)
      end
    end

    context 'with invalid params' do
      it 'assigns the mailchimp_update as @mailchimp_update' do
        skip('unknown, routing issue')
        mailchimp_update = MailchimpUpdate.create! valid_attributes
        put :update, params: { id: mailchimp_update.to_param, mailchimp_update: invalid_attributes }
        expect(assigns(:mailchimp_update)).to eq(mailchimp_update)
      end

      it "re-renders the 'edit' template" do
        skip('Will fix invalid tests later')
        mailchimp_update = MailchimpUpdate.create! valid_attributes
        put :update, params: { id: mailchimp_update.to_param, mailchimp_update: invalid_attributes }
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested mailchimp_update' do
      skip('unknown, routing issue')
      mailchimp_update = MailchimpUpdate.create! valid_attributes
      expect {
        delete :destroy, params: { id: mailchimp_update.to_param }
      }.to change(MailchimpUpdate, :count).by(-1)
    end

    it 'redirects to the mailchimp_updates list' do
      skip('unknown, routing issue')
      mailchimp_update = MailchimpUpdate.create! valid_attributes
      delete :destroy, params: { id: mailchimp_update.to_param }
      expect(response).to redirect_to(mailchimp_updates_url)
    end
  end
end
