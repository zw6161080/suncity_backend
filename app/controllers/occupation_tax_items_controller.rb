class OccupationTaxItemsController < ApplicationController
  include StatementBaseActions
  before_action :authorize_provident_fund, only: [:index, :columns, :options]

  def authorize_provident_fund
    authorize OccupationTaxItem
  end

  def send_export(query)
    occupation_tax_item_export_num = Rails.cache.fetch('occupation_tax_item_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+ occupation_tax_item_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('occupation_tax_item_export_number_tag', occupation_tax_item_export_num + 1)
    "#{I18n.t(self.controller_name+'.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
  end

  def filter(query)
    policy_scope(query)
  end

  def import
    authorize OccupationTaxItem
    begin
      OccupationTaxItem.import_xlsx(params[:file], Time.zone.parse(params[:year]))
      render json: { success: true }, status: :ok
    rescue LogicError => error
      render json: { message: error.message }, status: :unprocessable_entity
    end
  end


  # PATCH /occupation_tax_items/1
  def update_comment
    authorize OccupationTaxItem
    item = OccupationTaxItem.find(params[:id])
    if item.update(update_comment_params)
      render json: item
    else
      render json: item.errors, status: :unprocessable_entity
    end
  end

  def year_options
    render json: OccupationTaxItem.year_options,  adapter: :attributes
  end

  private

  def update_comment_params
    params.permit(
      :comment,
      :quarter_1_tax_mop_after_adjust,
      :quarter_2_tax_mop_after_adjust,
      :quarter_3_tax_mop_after_adjust
    )
  end
end
