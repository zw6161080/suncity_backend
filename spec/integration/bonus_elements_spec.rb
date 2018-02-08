require 'swagger_helper'

describe 'Bonus Elements API' do

  path '/bonus_elements' do
    get '获取所有浮动薪金项目' do
      tags '浮动薪金项目'
      consumes 'application/json'
      produces 'application/json'

      response '200', '获取成功' do
        schema type: :array, items: {
          type: :object,
          properties: {
            id: { type: :integer },
            chinese_name: { type: :string, description: '浮动薪金项目繁体中文名' },
            english_name: { type: :string, description: '浮动新进项目英文名' },
            simple_chinese_name: { type: :string, description: '浮动薪金项简体中文名' },
            key: { type: :string, description: '浮动薪金项目的KEY' },
            levels: { type: :array, items: { type: :string }, description: '浮动薪金项可能需要划分的级别， null或者 ["manager", "ordinary"]' },
            unit: { type: :string, description: '浮动薪金项的货币单位： hkd 或者 mop' },
            order: { type: :integer, description: '浮动薪金项目的排序' }
          }
        }
        run_test!
      end
    end
  end

  path '/bonus_elements/{id}' do
    get '获取浮动薪金项目' do
      tags '浮动薪金项目'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: '浮动薪金项目的ID'

      response '200', '获取成功' do
        schema type: :object, properties: {
          id: { type: :integer },
          chinese_name: { type: :string, description: '浮动薪金项目繁体中文名' },
          english_name: { type: :string, description: '浮动新进项目英文名' },
          simple_chinese_name: { type: :string, description: '浮动薪金项简体中文名' },
          key: { type: :string, description: '浮动薪金项目的KEY' },
          levels: { type: :array, items: { type: :string }, description: '浮动薪金项可能需要划分的级别， null或者 ["manager", "ordinary"]' },
          unit: { type: :string, description: '浮动薪金项的货币单位： hkd 或者 mop' },
          order: { type: :integer, description: '浮动薪金项目的排序' }
        }
        run_test!
      end
    end
  end

  path '/bonus_element_settings' do
    get '获取全部浮动薪金项目部门制/个人制设定' do
      tags '浮动薪金项目'
      consumes 'application/json'
      produces 'application/json'

      response '200', '获取成功' do

        run_test!
      end
    end
  end

  path '/bonus_element_settings/{id}' do
    get '获取浮动薪金项目部门制/个人制设定' do
      tags '浮动薪金项目'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: '浮动薪金项目【设定对象】的ID'

      response '200', '获取成功' do
        schema type: :array, items: {
          type: :object,
          properties: {
            id: { type: :integer, description: '浮动薪金项目设定对象的ID' },
            department_id: { type: :integer, description: '部门的ID' },
            location_id: { type: :integer, description: '场馆ID' },
            bonus_element_id: { type: :integer, description: '浮动薪金项的ID' },
            value: { type: :string, description: '设定的值 departmental / personal' }
          }
        }
        run_test!
      end
    end

    patch '更新浮动薪金部门制/个人制设定' do
      tags '浮动薪金项目'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: '浮动薪金项目【设定对象】的ID'

      response '200', '设定成功' do
        schema type: :object, properties: {
          id: { type: :integer, description: '浮动薪金项目设定对象的ID' },
          department_id: { type: :integer, description: '部门的ID' },
          location_id: { type: :integer, description: '场馆ID' },
          bonus_element_id: { type: :integer, description: '浮动薪金项的ID' },
          value: { type: :string, description: '设定的值 departmental / personal' }
        }

        run_test!
      end
    end
  end

  path '/bonus_element_settings/batch_update' do
    patch '批量更新浮动薪金项目部门制/个人制设定' do
      tags '浮动薪金项目'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :updates, in: :body, schema: {
        type: :array,
        items: {
          type: :object,
          properties: {
            department_id: { type: :integer },
            location_id: { type: :integer },
            bonus_element_id: { type: :integer },
            value: { type: :string }
          }
        }
      }

      response '200', '设定成功' do
        run_test!
      end
    end
  end

  path '/bonus_element_month_shares' do
    get '获取浮动薪金份数设定' do
      tags '浮动薪金部门设定'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :float_salary_month_entry_id, in: :query, type: :integer, description: '筛选浮动薪金月表id'
      parameter name: :year_month, in: :query, type: :integer, description: '筛选年月'
      parameter name: :location_id, in: :query, type: :integer, description: '筛选场馆id'
      parameter name: :department_id, in: :query, type: :integer, description: '筛选部门id'
      parameter name: :bonus_element_id, in: :query, type: :integer, description: '筛选浮动薪金项目id'

      response '200', '获取数据成功' do
        schema type: :array, items: {
          type: :object,
          properties: {
            id: { type: :integer },
            float_salary_month_entry_id: { type: :integer },
            bonus_element_id: { type: :integer },
            location_id: { type: :integer },
            department_id: { type: :integer },
            shares: { type: :string }
          }
        }
        run_test!
      end
    end
  end

  path '/bonus_element_month_shares/{id}' do
    get '获取浮动薪金份数设定' do
      tags '浮动薪金部门设定'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: '浮动薪金部门份数设定对象的ID'

      response '200', '获取数据成功' do
        schema type: :object, properties: {
          id: { type: :integer },
          float_salary_month_entry_id: { type: :integer },
          bonus_element_id: { type: :integer },
          location_id: { type: :integer },
          department_id: { type: :integer },
          shares: { type: :string }
        }
        run_test!
      end
    end
  end

  path '/bonus_element_month_shares/batch_update' do
    patch '批量更新浮动薪金份数设定' do
      tags '浮动薪金部门设定'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :updates, in: :body, schema: {
        type: :array,
        items: {
          type: :object,
          properties: {
            id: { type: :integer, description: '浮动薪金部门份数设定对象的ID' },
            shares: { type: :string, description: '浮动薪金份数，以字符串形式表达，避免浮点数误差' }
          }
        }
      }

      response '201', '更新数据成功' do
        run_test!
      end
    end
  end

  path '/bonus_element_month_amounts' do
    get '获取浮动薪金部门每份金额设定' do
      tags '浮动薪金部门设定'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :float_salary_month_entry_id, in: :query, type: :integer, description: '筛选浮动薪金月表id'
      parameter name: :year_month, in: :query, type: :integer, description: '筛选年月'
      parameter name: :location_id, in: :query, type: :integer, description: '筛选场馆id'
      parameter name: :department_id, in: :query, type: :integer, description: '筛选部门id'
      parameter name: :bonus_element_id, in: :query, type: :integer, description: '筛选浮动薪金项目id'

      response '200', '获取数据成功' do
        schema type: :object, properties: {
          id: { type: :integer },
          float_salary_month_entry_id: { type: :integer },
          bonus_element_id: { type: :integer },
          location_id: { type: :integer },
          department_id: { type: :integer },
          amount: { type: :string },
          level: { type: :string }
        }
        run_test!
      end
    end
  end

  path '/bonus_element_month_amounts/{id}' do
    get '获取浮动薪金部门每份金额设定' do
      tags '浮动薪金部门设定'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: '浮动薪金部门每份金额设定对象的ID'

      response '200', '获取数据成功' do
        schema type: :object, properties: {
          id: { type: :integer },
          float_salary_month_entry_id: { type: :integer },
          bonus_element_id: { type: :integer },
          location_id: { type: :integer },
          department_id: { type: :integer },
          amount: { type: :string },
          level: { type: :string }
        }
        run_test!
      end
    end

    patch '修改浮动薪金部门每份金额' do
      tags '浮动薪金部门设定'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: '浮动薪金部门每份金额设定对象的ID'
      parameter name: :amount, in: :body, type: :string

      response '201', '更新数据成功' do
        run_test!
      end
    end
  end

  path '/bonus_element_month_amounts/batch_update' do
    patch '批量修改浮动薪金每份金额' do
      tags '浮动薪金部门设定'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :updates, in: :body, schema: {
        type: :array,
        items: {
          type: :object,
          properties: {
            id: { type: :integer, description: '浮动薪金部门每份金额设定对象的ID' },
            amount: { type: :string, description: '浮动薪金每份金额，以字符串形式表达，避免浮点数误差' }
          }
        }
      }

      response '201', '更新数据成功' do
        run_test!
      end
    end
  end

  path '/bonus_element_items' do
    get '获取浮动薪金个人数值' do
      tags '浮动薪金个人'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :float_salary_month_entry_id, in: :query, type: :integer, required: true, description: '浮动薪金月表ID'
      parameter name: :employee_id, in: :query, type: :string, description: '员工编号'
      parameter name: :employee_name, in: :query, type: :string, description: '员工姓名'
      parameter name: :location_ids, in: :query, type: :array, description: '场馆ID', items: { type: :integer }
      parameter name: :department_ids, in: :query, type: :array, description: '部门ID', items: { type: :integer }
      parameter name: :position_ids, in: :query, type: :array, description: '职位ID', items: { type: :integer }
      parameter name: :sort_column, in: :query, type: :string, description: '排序列的KEY', enum: [ 'employee_id', 'employee_name', 'location_ids', 'department_ids', 'position_ids' ]
      parameter name: :sort_direction, in: :query, type: :string, description: '排序方向', enum: [ 'asc', 'desc' ]

      response '200', '请求成功' do
        schema type: :object, properties: {
          data: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :integer },
                user_id: { type: :integer },
                float_salary_month_entry_id: { type: :integer }
              }
            }
          },
          meta: {
            type: :object,
            properties: {
              total_count: { type: :integer },
              current_page: { type: :integer },
              total_pages: { type: :integer },
            }
          }
        }
        run_test!
      end
    end
  end

  path '/bonus_element_items/options' do
    get '获取浮动薪金的下拉筛选项' do
      tags '浮动薪金个人'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :float_salary_month_entry_id, in: :query, type: :integer, required: true, description: '浮动薪金月表ID'

      response '200', '请求成功' do
        schema type: :object, properties: {
          departments: {
            type: :array,
            items: {
              '$ref' => '#/definitions/department'
            }
          },
          positions: {
            type: :array,
            items: {
              '$ref' => '#/definitions/position'
            }
          },
          locations: {
            type: :array,
            items: {
              '$ref' => '#/definitions/location'
            }
          },
        }

        run_test!
      end
    end
  end

  path '/bonus_element_items/{id}' do
    get '获取浮动薪金个人数值' do
      tags '浮动薪金个人'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true, description: '浮动薪金个人数值条目的ID'

      response '200', '请求成功' do
        schema type: :object, properties: {
          id: { type: :integer },
          user_id: { type: :integer },
          float_salary_month_entry_id: { type: :integer }
        }
        run_test!
      end
    end
  end

  path '/bonus_element_item_values/{id}' do

    get '读取浮动薪金个人数值设定' do
      tags '浮动薪金个人'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true, description: '浮动薪金个人数值设定对象的ID'

      response '200', '请求成功' do
        schema type: :object, properties: {
          id: { type: :integer },
          bonus_element_item_id: { type: :integer },
          bonus_element_id: { type: :integer },
          value_type: { type: :string, description: '个人设定的类型：  personal / departmental' },
          shares: { type: :string, description: '份数数值的字符串表示  9.99' },
          pre_share: { type: :string, description: '每份数值的字符串表示  9.99' },
          amount: { type: :string, description: '个人总数数值的字符串表示  9.99' },
        }
        run_test!
      end
    end

    patch '更新浮动薪金个人数值设定' do
      tags '浮动薪金个人'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true, description: '浮动薪金个人数值设定对象的ID'
      parameter name: :shares, in: :body, type: :string, description: '份数数值的字符串表示  9.99'
      parameter name: :pre_share, in: :body, type: :string, description: '每份数值的字符串表示  9.99'
      parameter name: :amount, in: :body, type: :string, description: '个人总数数值的字符串表示  9.99'

      response '200', '请求成功' do
        run_test!
      end
    end

  end

end