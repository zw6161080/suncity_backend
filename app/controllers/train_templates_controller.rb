class TrainTemplatesController < ApplicationController
  before_action :set_train_template, only: [:show, :update, :destroy]
  include ActionController::MimeResponds
  include SortParamsHelper
  include TrainTemplateHelper

  def all_templates
    render json: TrainTemplate.all, root: 'data'
  end

  # GET /train_templates
  def index
    authorize TrainTemplate
    sort_column = sort_column_sym(final_sort_column(params[:sort_column],'TrainTemplate'), :created_at)
    sort_direction = sort_direction_sym(params[:sort_direction], :asc)
    query = search_query.by_order(sort_column, sort_direction)
    respond_to do |format|
      format.json {
        query = query.page.page(params.fetch(:page, 1)).per(20)
        meta = {
            total_count: query.total_count,
            current_page: query.current_page,
            total_pages: query.total_pages,
            sort_column: sort_column.to_s,
            sort_direction: sort_direction.to_s,
        }
        data = query.as_json(include: [
            { train_template_type: {} },
            { creator: {} }
        ])
        response_json data, meta: meta
      }
    end
  end

  # GET /train_templates/1
  def show
    authorize TrainTemplate
    response_json @train_template.as_json(include: [
        {exam_template: {include:{ fill_in_the_blank_questions:{} , choice_questions: {include: :options }, matrix_single_choice_questions: {include:  {matrix_single_choice_items: {}}}}}},
        { train_template_type: {} },
        {attend_attachments: {include: :creator}},
        {online_materials:{include: :creator}}
    ])
  end

  # POST /train_templates
  def create
    authorize TrainTemplate
    train_template_id = TrainTemplate.create_with_params(
        params.permit(*TrainTemplate.create_params).merge({ creator_id: current_user.id }),
        params[:online_materials]&.map{ |item| item.permit(*OnlineMaterial.create_params).merge({ creator_id: current_user.id }) },
        params[:attend_attachments]&.map{ |item| item.permit(*AttendAttachment.create_params).merge({ creator_id: current_user.id }) },
        params[:exam_template_id],
        params[:fill_in_the_blank_questions],
        params[:choice_questions],
        params[:matrix_single_choice_questions]
    )
    response_json train_template_id
  end

  # PATCH/PUT /train_templates/1
  def update
    authorize TrainTemplate
    result = @train_template.update_with_params(
        params.permit(*TrainTemplate.create_params).merge({ creator_id: current_user.id }),
        params[:online_materials]&.map{ |item| item.permit(*OnlineMaterial.create_params).merge({ creator_id: current_user.id }) },
        params[:attend_attachments]&.map{ |item| item.permit(*AttendAttachment.create_params).merge({ creator_id: current_user.id }) },
        params[:fill_in_the_blank_questions],
        params[:choice_questions],
        params[:matrix_single_choice_questions]
    )
    if result
      render json: result
    else
      render json: result, status: :unprocessable_entity
    end
  end

  def field_options
    response_json TrainTemplate.field_options
  end

  private

    def search_query
      updated_at_begin = Time.zone.parse(params[:updated_at_begin]).beginning_of_day rescue nil
      updated_at_end = Time.zone.parse(params[:updated_at_end]).end_of_day rescue nil
      TrainTemplate.joins_train_template_type_and_creator
          .by_course_number(params[:course_number])
          .by_course_name(params[:course_name])
          .by_train_template_type_id(params[:train_template_type_id])
          .by_training_credits(params[:training_credits])
          .by_exam_format(params[:exam_format])
          .by_assessment_method(params[:assessment_method])
          .by_creator_name(params[:creator_name])
          .by_updated_at(updated_at_begin,updated_at_end)
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_train_template
      @train_template = TrainTemplate.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def train_template_params
      TrainTemplate.create_with_params(params.permit(
          *TrainTemplate.create_params).merge({ creator_id: current_user.id }),
          params[:online_materials]&.map { |item| item.permit(*OnlineMaterial.create_params).merge({ creator_id: current_user.id }) },
          params[:attend_attachments]&.map { |item| item.permit(*OnlineMaterial.create_params).merge({ creator_id: current_user.id }) },
                                       params[:exam_template_id],
                                       params[:fill_in_the_blank_questions],
                                       params[:choice_questions],
                                       params[:matrix_single_choice_questions])
    end
end
