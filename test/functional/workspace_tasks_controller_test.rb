require 'test_helper'

class WorkspaceTasksControllerTest < ActionController::TestCase
  setup do
    @workspace_task = workspace_tasks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:workspace_tasks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create workspace_task" do
    assert_difference('WorkspaceTask.count') do
      post :create, workspace_task: { assigned_id: @workspace_task.assigned_id, author_id: @workspace_task.author_id, auto_task: @workspace_task.auto_task, description: @workspace_task.description, priority: @workspace_task.priority, state: @workspace_task.state, subject: @workspace_task.subject }
    end

    assert_redirected_to workspace_task_path(assigns(:workspace_task))
  end

  test "should show workspace_task" do
    get :show, id: @workspace_task
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @workspace_task
    assert_response :success
  end

  test "should update workspace_task" do
    put :update, id: @workspace_task, workspace_task: { assigned_id: @workspace_task.assigned_id, author_id: @workspace_task.author_id, auto_task: @workspace_task.auto_task, description: @workspace_task.description, priority: @workspace_task.priority, state: @workspace_task.state, subject: @workspace_task.subject }
    assert_redirected_to workspace_task_path(assigns(:workspace_task))
  end

  test "should destroy workspace_task" do
    assert_difference('WorkspaceTask.count', -1) do
      delete :destroy, id: @workspace_task
    end

    assert_redirected_to workspace_tasks_path
  end
end
