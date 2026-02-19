class ActivitiesController < ApplicationController
  before_action :set_contact
  before_action :set_activity, only: [ :show, :edit, :update, :destroy ]

  # GET /activities            — global activity log (full two-panel layout)
  # GET /contacts/:id/activities — per-contact panel (lazy-loaded via up-defer)
  def index
    if @contact
      @activities = @contact.activities.order(created_at: :desc)
      @activities = @activities.where(kind: params[:kind]) if params[:kind].present?
      @activity   = Activity.new
    else
      @q    = params[:q].to_s.strip
      @kind = params[:kind].to_s

      activities = Activity.joins(:contact).includes(:contact).order(created_at: :desc)
      activities = activities.where(kind: @kind) if @kind.present?
      if @q.present?
        q = "%#{@q}%"
        activities = activities.where(
          "activities.body LIKE :q OR contacts.last_name LIKE :q OR contacts.first_name LIKE :q", q: q
        )
      end

      @activities_by_day = activities.group_by { |a| a.created_at.to_date }
      render :global_index
    end
  end

  # GET /activities/:id — overlay detail view
  def show
  end

  # GET /activities/new — overlay form to log an activity for any contact
  def new
    @contacts = Contact.active.order(:last_name, :first_name)
    @activity = Activity.new
  end

  # GET /activities/:id/edit — overlay edit form
  def edit
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

  # PATCH /activities/:id
  def update
    if @activity.update(activity_params.except(:contact_id))
      up.cache.expire("/activities")
      up.cache.expire("/contacts/#{@activity.contact.id}/activities")
      if up.layer.overlay?
        up.layer.accept
        head :no_content
      else
        redirect_to activities_path
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /activities/:id
  def destroy
    contact = @activity.contact
    @activity.destroy
    up.cache.expire("/activities")
    up.cache.expire("/contacts/#{contact.id}/activities")

    filter_params = { q: params[:q], kind: params[:kind] }.reject { |_, v| v.blank? }

    if up.layer.overlay?
      up.layer.accept
      head :no_content
    elsif up? && up.target?("#activities-panel")
      redirect_to contact_activities_path(contact, filter_params.slice(:kind))
    else
      redirect_to activities_path(filter_params)
    end
  end

  private

  def set_contact
    @contact = Contact.find(params[:contact_id]) if params[:contact_id].present?
  end

  def set_activity
    @activity = Activity.find(params[:id])
    @contact ||= @activity.contact
  end

  def activity_params
    params.require(:activity).permit(:kind, :body, :contact_id)
  end
end
