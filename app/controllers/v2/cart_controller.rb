class CartController < ApplicationController
  include ApplicationHelper
  before_action :init_cart
  # Index
  def index
    @people_ids = @session[:cart]
  end

  # Add
  def add
    people_ids = @session[:cart]
    # If exists, add new, else create new variable
    if people_ids && people_ids != []
      session[:cart] << cart_params[:people_ids]
    else
      session[:cart] = Array(cart_params[:people_ids])
    end
    session[:cart].map(&:to_i).uniq!
    render json: session[:cart].to_json
  end

  # Delete
  def delete
    people_ids = @session[:cart]

    to_delete = cart_params[:people_ids]
    all = params[:all]
    # Is ID present?
    unless to_delete.blank?
      unless all.blank?
        session[:cart].delete(cart_params[:people_ids])
      else
        session[:cart].delete_if {|c| cart_params[:people_ids].include?(c) }
      end
    else
      session[:cart] = []
    end
    render json: session[:cart].to_json
  end

  private

  def car_params
    params.permit(:people_ids, :all)
  end

  def init_cart
    @session = session
    @session[:cart] ||= []
    @session[:cart].map(&:to_i).uniq!
  end
end
