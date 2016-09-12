require 'csv'

class GiftCardsController < ApplicationController
  before_action :set_gift_card, only: [:show, :edit, :update, :destroy]

  # GET /gift_cards
  # GET /gift_cards.json
  def index
    @q_giftcards = GiftCard.ransack(params[:q])
    respond_to do |format|
      format.html do
        @gift_cards = @q_giftcards.result.includes(:person).page(params[:page])
        @recent_signups = Person.no_signup_card.paginate(page: params[:page]).where('signup_at > :startdate', { startdate: 3.months.ago }).order('signup_at DESC')
        @new_gift_cards = []
        @recent_signups.length.times do
          @new_gift_cards << GiftCard.new
        end
      end
      format.csv do
        @gift_cards = @q_giftcards.result.includes(:person)
        send_data @gift_cards.export_csv,  filename: "GiftCards-#{Date.today}.csv"
      end
    end
  end

  # GET /gift_cards/1
  # GET /gift_cards/1.json
  def show
  end

  # GET /gift_cards/new
  def new
    @gift_card = GiftCard.new
  end

  # GET /gift_cards/1/edit
  def edit
  end

  # POST /gift_cards
  # POST /gift_cards.json
  def create
    @gift_card = GiftCard.new(gift_card_params)
    respond_to do |format|
      if @create_result = @gift_card.with_user(current_user).save
        @total = @gift_card.person.blank? ? @gift_card.amount : @gift_card.person.gift_card_total
        format.js {}
        format.json {}
        format.html { redirect_to @gift_card, notice: 'Gift Card was successfully created.'  }
      else
        format.js {}
        format.html { render action: 'edit' }
        format.json { render json: @gift_card.errors, status: :unprocessable_entity }
      end
    end

    # respond_to do |format|
    #   if @gift_card.save
    #     format.html { redirect_to @gift_card, notice: 'Gift card was successfully created.' }
    #     format.json { render action: 'show', status: :created, location: @gift_card }
    #   else
    #     format.html { render action: 'new' }
    #     format.json { render json: @gift_card.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /gift_cards/1
  # PATCH/PUT /gift_cards/1.json
  def update
    respond_to do |format|
      if @gift_card.update(gift_card_params)
        format.html { redirect_to @gift_card, notice: 'Gift card was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @gift_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gift_cards/1
  # DELETE /gift_cards/1.json
  def destroy
    @gift_card.destroy
    respond_to do |format|
      format.html { redirect_to gift_cards_url }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_gift_card
      @gift_card = GiftCard.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gift_card_params
      params.require(:gift_card).permit(:gift_card_number, :batch_id, :expiration_date, :person_id, :notes, :proxy_id, :created_by, :reason, :amount, :giftable_id, :giftable_type)
    end
end
