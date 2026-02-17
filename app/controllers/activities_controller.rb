class ActivitiesController < ApplicationController
  before_action :set_contact

  def index
    @activities = @contact.activities.order(created_at: :desc)
    @activity = Activity.new
  end

  def create
    @activity = @contact.activities.build(activity_params)
    if @activity.save
      redirect_to contact_activities_path(@contact)
    else
      @activities = @contact.activities.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_contact
    @contact = Contact.find(params[:contact_id])
  end

  def activity_params
    params.require(:activity).permit(:kind, :body)
  end
end
