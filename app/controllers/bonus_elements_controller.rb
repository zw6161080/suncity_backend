class BonusElementsController < ApplicationController
  before_action :set_bonus_element, only: [:show, :update, :destroy]

  # GET /bonus_elements
  def index
    @bonus_elements = BonusElement.all.order(:order => :asc)

    render json: @bonus_elements
  end

  # GET /bonus_elements/1
  def show
    render json: @bonus_element
  end

  # POST /bonus_elements
  def create
    @bonus_element = BonusElement.new(bonus_element_params)

    if @bonus_element.save
      render json: @bonus_element, status: :created, location: @bonus_element
    else
      render json: @bonus_element.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /bonus_elements/1
  def update
    if @bonus_element.update(bonus_element_params)
      render json: @bonus_element
    else
      render json: @bonus_element.errors, status: :unprocessable_entity
    end
  end

  # DELETE /bonus_elements/1
  def destroy
    @bonus_element.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bonus_element
      @bonus_element = BonusElement.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def bonus_element_params
      params.fetch(:bonus_element, {})
    end
end
