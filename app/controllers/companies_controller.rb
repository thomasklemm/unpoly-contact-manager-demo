class CompaniesController < ApplicationController
  after_action :expire_contacts_cache, only: [ :create ]

  # index and show have their own data; no contacts sidebar on those pages.
  skip_before_action :load_sidebar_contacts, only: [ :index, :show ]

  def index
    @companies = Company.order(:name)
  end

  def show
    @company = Company.find(params[:id])
    @contacts = @company.contacts.active.order(:first_name, :last_name)
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      if up.layer.overlay?
        # Accept with {id:, name:} so up-on-accepted can build the <option> element.
        up.layer.accept({ id: @company.id, name: @company.name })
        head :no_content
      else
        flash[:notice] = "#{@company.name} was created."
        redirect_to companies_path
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def company_params
    params.require(:company).permit(:name, :website)
  end

  def expire_contacts_cache
    up.cache.expire("/contacts*")
  end
end
