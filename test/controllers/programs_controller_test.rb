# == Schema Information
#
# Table name: programs
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text(65535)
#  created_at  :datetime
#  updated_at  :datetime
#  created_by  :integer
#  updated_by  :integer
#

require 'test_helper'

class ProgramsControllerTest < ActionController::TestCase

  setup do
    @program = programs(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:programs)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create program' do
    assert_difference('Program.count') do
      post :create, program: { description: @program.description, name: @program.name }
    end

    assert_equal users(:admin).id, assigns(:program).created_by
    assert_redirected_to program_path(assigns(:program))
  end

  test 'should show program' do
    get :show, id: @program
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @program
    assert_response :success
  end

  test 'should update program' do
    patch :update, id: @program, program: { description: @program.description, name: @program.name }
    assert_redirected_to program_path(assigns(:program))
  end

  test 'should destroy program' do
    assert_difference('Program.count', -1) do
      delete :destroy, id: @program
    end

    assert_redirected_to programs_path
  end

end
