# == Schema Information
#
# Table name: taggings
#
#  id            :integer          not null, primary key
#  taggable_type :string(255)
#  taggable_id   :integer
#  created_by    :integer
#  created_at    :datetime
#  updated_at    :datetime
#  tag_id        :integer
#

class TaggingsController < ApplicationController

  # FIXME: Refactor and re-enable cop
  # rubocop:disable Metrics/MethodLength
  #
  def create
    @tag = Tag.find_or_initialize_by(name: params[:tagging].delete(:name))
    @tag.created_by ||= current_user.id
    @tagging = Tagging.new(taggable_type: params[:tagging][:taggable_type], taggable_id: params[:tagging][:taggable_id], tag: @tag)

    if @tagging.with_user(current_user).save
      respond_to do |format|
        format.js {}
      end
    else
      respond_to do |format|
        format.js { render text: "alert('Oh no! You can only tag an item with a given tag once.')" }
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  def destroy
    @tagging = Tagging.find(params[:id])

    if @tagging.destroy
      respond_to do |format|
        format.js {}
      end
    else
      respond_to do |format|
        format.js { render text: "alert('failed to destroy tag.')" }
      end
    end
  end

  def search
    @tags = Tag.where('name like ?', "#{params[:q]}%").
            order(taggings_count: :desc)
    render json: @tags
  end

end
