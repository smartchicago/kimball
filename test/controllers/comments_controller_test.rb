# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  content          :text(65535)
#  user_id          :integer
#  commentable_type :string(255)
#  commentable_id   :integer
#  created_at       :datetime
#  updated_at       :datetime
#  created_by       :integer
#

require 'test_helper'

class CommentsControllerTest < ActionController::TestCase

  setup do
    @comment = comments(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:comments)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create comment' do
    assert_difference('Comment.count') do
      post :create, comment: { commentable_id: @comment.commentable_id, commentable_type: @comment.commentable_type, content: @comment.content, user_id: @comment.user_id }, format: :js
    end

    assert_response :success
  end

  test 'should show comment' do
    get :show, id: @comment
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @comment
    assert_response :success
  end

  test 'should update comment' do
    patch :update, id: @comment, comment: { commentable_id: @comment.commentable_id, commentable_type: @comment.commentable_type, content: @comment.content, user_id: @comment.user_id }
    assert_redirected_to comment_path(assigns(:comment))
  end

  test 'should destroy comment' do
    assert_difference('Comment.count', -1) do
      delete :destroy, id: @comment, format: :js
    end

    assert_response :success
  end

end
