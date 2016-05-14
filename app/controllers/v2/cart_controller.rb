class V2::CartController < ApplicationController
  include ApplicationHelper

  # Index
  def index
    init
    render json: session[:cart].to_json
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def add
    init
    to_add = cart_params[:person_id].to_i
    person = Person.find_by(id: to_add) # only people ids here.

    session[:cart] << person.id unless session[:cart].include?(person.id) || person.nil?

    @added = person.id
    respond_to do |format|
      format.js
      format.json { render json: session[:cart].to_json }
      format.html { render json: session[:cart].to_json }
    end
  end

  # Delete
  def delete
    init
    to_delete = cart_params[:person_id].to_i
    if params[:all].blank?
      @deleted = session[:cart].delete(to_delete) unless to_delete.blank?
    else
      @deleted = session[:cart]
      session[:cart] = []
    end

    respond_to do |format|
      format.js
      format.json { render json: session[:cart].to_json }
      format.html { render json: session[:cart].to_json }
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  private

    def cart_params
      # person id is a single int.
      params.permit(:person_id, :all)
    end

    def init
      # this is a bit of a hack here.
      # before filter seems to break things. I don't know why
      session[:cart] = (session[:cart] ||= []).map(&:to_i).uniq - [0]
    end
end
