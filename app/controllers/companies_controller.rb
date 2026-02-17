class CompaniesController < ApplicationController
  after_action :expire_contacts_cache, only: [ :create ]

  def index
    @companies = Company.order(:name)
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      if up.layer.overlay?
        # Accept the modal with the new company's id so the parent form can
        # inject it into the company select via up-on-accepted.
        up.layer.accept(@company.id)
        up.render_nothing
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
