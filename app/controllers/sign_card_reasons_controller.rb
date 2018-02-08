class SignCardReasonsController < ApplicationController

  before_action :set_sign_card_setting, only: [:create]
  before_action :set_sign_card_reason, only: [:update, :destroy]

  def create
    # authorize SignCardReason
    sign_card_reason = @sign_card_setting.sign_card_reasons.create(sign_card_reason_params)
    response_json sign_card_reason.id
  end

  def update
    # authorize SignCardReason
    result = @sign_card_reason.update(sign_card_reason_params)
    response_json result
  end

  def destroy
    # authorize SignCardReason
    @sign_card_reason.destroy unless @sign_card_reason.be_used
    response_json @sign_card_reason.id
  end

  private

  def set_sign_card_setting
    @sign_card_setting = SignCardSetting.find(params[:sign_card_setting_id])
  end

  def set_sign_card_reason
    @sign_card_reason = SignCardReason.find(params[:id])
  end

  def sign_card_reason_params
    params.require(:sign_card_reason).permit(
      :region,
      :reason,
      :reason_code,
      :comment
    )
  end
end
