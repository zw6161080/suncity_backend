class SignCardSettingsController < ApplicationController
  before_action :set_sign_card_setting, only: [:update]

  def index_by_current_user
    raw_index
  end

  def raw_index
    SignCardSetting.start_init_table
    SignCardSetting.set_be_used
    response_json SignCardSetting.all.order(code: :asc).as_json(
      include: {
        sign_card_reasons: {}
      }
    )
  end

  def index
    # authorize SignCardSetting
    raw_index
  end

  def update
    # authorize SignCardSetting
    @sign_card_setting.update(sign_card_setting_params)
    response_json @sign_card_setting.id
  end

  private

  def set_sign_card_setting
    @sign_card_setting = SignCardSetting.find(params[:id])
  end

  def sign_card_setting_params
    params.require(:sign_card_setting).permit(
      :region,
      :comment
    )
  end
end
