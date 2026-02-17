class ContactsController < ApplicationController
  before_action :set_contact, only: [ :show, :edit, :update, :destroy, :star, :archive ]
  after_action :expire_contacts_cache, only: [ :create, :update, :destroy, :star, :archive ]

  def index
    @contacts = filtered_contacts
  end

  def show
  end

  def new
    @contact = Contact.new
    @companies = Company.order(:name)
    @tags = Tag.order(:name)
  end

  def create
    @contact = Contact.new(contact_params)

    # up.validate? — per-field validation (X-Up-Validate header)
    # up? && up.target? — up-watch reactive company select (only when Unpoly sent X-Up-Target)
    # Note: up.target? returns true for ALL non-Unpoly requests, so guard with up? first
    if up.validate? || (up? && up.target?("#company-fields"))
      @contact.valid? if up.validate?
      @companies = Company.order(:name)
      @tags = Tag.order(:name)
      render :new, status: :unprocessable_entity
      return
    end

    if @contact.save
      flash[:notice] = "#{@contact.full_name} was added."
      if up.layer.overlay?
        up.layer.accept(contact_path(@contact))
        head :no_content
      else
        redirect_to contact_path(@contact)
      end
    else
      @companies = Company.order(:name)
      @tags = Tag.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @companies = Company.order(:name)
    @tags = Tag.order(:name)
  end

  def update
    # Same guard as create: only intercept when it's an actual Unpoly request
    if up.validate? || (up? && up.target?("#company-fields"))
      @contact.assign_attributes(contact_params)
      @contact.valid? if up.validate?
      @companies = Company.order(:name)
      @tags = Tag.order(:name)
      render :edit, status: :unprocessable_entity
      return
    end

    if @contact.update(contact_params)
      flash[:notice] = "#{@contact.full_name} was updated."
      if up.layer.overlay?
        up.layer.accept(contact_path(@contact))
        head :no_content
      else
        redirect_to contact_path(@contact)
      end
    else
      @companies = Company.order(:name)
      @tags = Tag.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact.destroy
    flash[:notice] = "Contact was deleted."
    redirect_to contacts_path
  end

  def star
    @contact.update!(starred: !@contact.starred?)
    redirect_to contact_path(@contact)
  end

  def archive
    if @contact.archived?
      @contact.update!(archived_at: nil)
      flash[:notice] = "#{@contact.full_name} was unarchived."
    else
      @contact.update!(archived_at: Time.current)
      flash[:notice] = "#{@contact.full_name} was archived."
    end
    redirect_to contacts_path
  end

  private

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(
      :first_name, :last_name, :email, :phone,
      :company_id, :notes, :starred,
      tag_ids: []
    )
  end

  def filtered_contacts
    contacts = Contact.includes(:company, :tags)

    case params[:filter]
    when "starred"
      contacts = contacts.starred
    when "archived"
      contacts = contacts.archived
    else
      contacts = contacts.active
    end

    if params[:q].present?
      q = "%#{params[:q]}%"
      contacts = contacts.where(
        "first_name LIKE ? OR last_name LIKE ? OR email LIKE ? OR (first_name || ' ' || last_name) LIKE ?",
        q, q, q, q
      )
    end

    contacts.order(:last_name, :first_name)
  end

  def expire_contacts_cache
    up.cache.expire("/contacts*")
  end
end
