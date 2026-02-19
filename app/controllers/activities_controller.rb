class ActivitiesController < ApplicationController
  before_action :set_contact

  # GET /activities            — global activity log (full two-panel layout)
  # GET /contacts/:id/activities — per-contact panel (lazy-loaded via up-defer)
  def index
    if @contact
      @activities = @contact.activities.order(created_at: :desc)
      @activity = Activity.new
    else
      @activities_by_day = Activity.includes(:contact)
                                   .order(created_at: :desc)
                                   .group_by { |a| a.created_at.to_date }
      render :global_index
    end
  end

  # GET /activities/new — overlay form to log an activity for any contact
  def new
    @contacts = Contact.active.order(:last_name, :first_name)
    @activity = Activity.new
  end

  # POST /contacts/:id/activities — per-contact create (from contact detail panel)
  # POST /activities             — global create (contact_id in form params)
  def create
    if @contact
      @activity = @contact.activities.build(activity_params)
      if @activity.save
        redirect_to contact_activities_path(@contact)
      else
        @activities = @contact.activities.order(created_at: :desc)
        render :index, status: :unprocessable_entity
      end
    else
      @contact = Contact.find_by(id: activity_params[:contact_id])
      if @contact.nil?
        @contacts = Contact.active.order(:last_name, :first_name)
        @activity = Activity.new(activity_params.except(:contact_id))
        @activity.errors.add(:contact_id, "must be selected")
        render :new, status: :unprocessable_entity and return
      end
      @activity = @contact.activities.build(activity_params.except(:contact_id))
      if @activity.save
        if up.layer.overlay?
          up.layer.accept
          head :no_content
        else
          redirect_to activities_path
        end
      else
        @contacts = Contact.active.order(:last_name, :first_name)
        render :new, status: :unprocessable_entity
      end
    end
  end

  private

  def set_contact
    @contact = Contact.find(params[:contact_id]) if params[:contact_id].present?
  end

  def activity_params
    params.require(:activity).permit(:kind, :body, :contact_id)
  end
end
