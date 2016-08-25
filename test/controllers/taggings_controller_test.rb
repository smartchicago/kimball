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

require 'test_helper'

class TaggingsControllerTest < ActionController::TestCase

  test 'should get create' do
    post :create, format: :js, tagging: { name: 'foo', taggable_type: 'Person', taggable_id: people(:one).id }
    assert_response :success
  end

  test 'should get destroy' do
    delete :destroy, format: :js, id: taggings(:one)
    assert_response :success
  end

end
