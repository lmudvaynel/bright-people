class ActivitiesController < ApplicationController
  # TODO: bugaggagga make it better, and try understand what every line do ;)
  before_filter :get_kind, only: :index
  before_filter :get_directions, only: :index
  before_filter :load_object, only: [:show, :get_comments]

  def index
    if request.xhr?
      @activities = search
      render partial: 'activities/activities', locals: {activities: @activities}
    else
      @activities = Activity.by_kind(@kind)
      # @activities = @activities.page(params[:page]).per(10)
    end
  end

  def show
  end

  def vote
    @activity = Activity.find(params[:activity_id])
    ActivityVote.update_rating(current_user, @activity, params[:rating].to_f)
    render partial: 'vote_count'
  end

  def get_comments
    scope = params[:type] == 'parents' ? 'parents' : 'childrens'
    comments = @activity.activity_comments.send(scope).page(params[:page]).per(5)
    render partial: 'activity_comment', locals: {comments: comments}
  end

  private

  def load_object
    @activity = Activity.find(params[:id])
  end

  def search
    activities = Activity.by_kind(@kind)
    activities = activities.approved if params[:only_approved].present?
    activities = activities.by_age(params[:age]) if params[:age].present?
    activities = activities.by_tag(params[:tag]) if params[:tag].present?
    activities = activities.by_metro(params[:metro]) if params[:metro].present?

    activities = case params[:order_by]
                 when 'title' then activities.order('title ASC')
                 when 'created_at' then activities.order('created_at DESC')
                 when 'users_rating' then activities.order('users_rating DESC')
                 else
                   activities.order('created_at DESC')
    end

    return activities
  end

  # TODO: create check params. More secure!!!
  def get_kind
    @kind = params[:kind] || 'educational'
  end

  def get_directions
    @directions = DirectionTag.send(@kind.to_sym)
  end

end
