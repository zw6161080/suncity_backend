require "test_helper"

class TrainTemplateTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    TrainTemplateTypesController.any_instance.stubs(:authorize).returns(true)
    TrainTemplateTypesController.any_instance.stubs(:current_user).returns(@current_user = create(:user))
  end

  test 'train_template_type can be delete' do
    train_template_type = create(:train_template_type)
    get can_be_delete_train_template_type_url(train_template_type.id)
    assert_response :ok
    assert_equal json_res['data'], true
    TrainTemplate.any_instance.stubs(:pluck).with(:train_template_type_id).returns([train_template_type.id])
    TrainTemplate.stubs(:pluck).with(:train_template_type_id).returns([train_template_type.id])
    get can_be_delete_train_template_type_url(train_template_type.id)
    assert_response :ok
    assert_equal json_res['data'], false

    test_train_tempate_type =  create(:train_template_type)

    patch batch_update_train_template_types_url, params: {
        create:[{
                    chinese_name: 'test1',
                    simple_chinese_name: 'test2',
                    english_name: 'test3'
                }
        ],
        update:[{
                    id:train_template_type.id,
                    chinese_name: 'test2'
                }
        ],
        delete:[test_train_tempate_type.id]
    }, as: :json

    assert_response :ok
    assert_equal TrainTemplateType.find_by_english_name('test3').chinese_name, 'test1'
    assert_equal TrainTemplateType.find(train_template_type.id).chinese_name, 'test2'
    assert TrainTemplateType.where(id: test_train_tempate_type.id).empty?


    get train_template_types_url
    assert_response :ok
    assert_equal json_res['data'].count ,     2
    patch batch_update_train_template_types_url, params: {
        delete:[train_template_type.id]
    }, as: :json

    assert_response :ok

    get train_template_types_url
    assert_response :ok
    assert_equal json_res['data'].count ,     2

  end

end
