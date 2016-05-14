class V2::CartController < ApplicationController
  include ApplicationHelper

  # Index
  def index
    init
    render json: session[:cart].to_json
  end

  # Add
  def add
    init
    to_add = cart_params[:person_id].to_i
    person = Person.find_by(id: to_add) # only people ids here.
    unless session[:cart].include?(person) || person.nil?
      session[:cart] << cart_params[:person_id].to_i
    end
    render json: session[:cart].to_json
  end

  # Delete
  def delete
    init
    to_delete = cart_params[:person_id].to_i
    all = params[:all]
    # Is ID present?
    if all.blank?
      session[:cart].delete(to_delete) unless to_delete.blank?
    else
      session[:cart] = []
    end
    render json: session[:cart].to_json
  end

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
