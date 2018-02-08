class SelectOptionsController < ApplicationController

  def index
    options = Select.get_options(params[:key].to_sym)

    response_json options
  end
end
