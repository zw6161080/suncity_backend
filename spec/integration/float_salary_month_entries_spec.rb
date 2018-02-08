require 'swagger_helper'

describe 'Float Salary Month Entries API' do
  path '/float_salary_month_entries/{id}/locations_with_departments' do
    get '获取每月浮动薪金相关的部门职位信息' do
      tags '浮动薪金设定'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true, description: '浮动薪金月份条目的ID'

      response '200', '请求成功' do
        schema type: :array, items: { type: :object, properties: {
          id: {type: :string, description: '场馆id'},
          chinese_namme: {type: :string, description: '中文姓名'},
          english_namme: {type: :string, description: '英文姓名'},
          simple_chinese_namme: {type: :string, description: '简体姓名'},
          departments: {type: :array, items: { type: :object, properties: {
            id: {type: :string, description: '场馆id'},
            chinese_namme: {type: :string, description: '中文姓名'},
            english_namme: {type: :string, description: '英文姓名'},
            simple_chinese_namme: {type: :string, description: '简体姓名'}
          }}}
        }}
        run_test!
      end
    end
  end

  path '/float_salary_month_entries' do

    get '获取浮动信息月份条目数据' do
      tags '浮动薪金设定'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :year, in: :query, type: :string, description: '筛选年份 YYYY'
      parameter name: :page, in: :query, type: :integer, description: '分页页码'

      response '200', '请求成功' do
        schema type: :object, properties: {
          data: {
            type: :object,
            properties: {
              year_month: { type: :string, description: '年月' },
              status: { type: :string, description: '状态  not_approved / approved' },
              employees_count: { type: :integer, description: '员工数量' }
            }
          },
          meta: {
            type: :object,
            properties: {
              total_count: { type: :integer, description: '数据总数' },
              current_page: { type: :integer, description: '当前页码' },
              total_pages: { type: :integer, description: '总页数' }
            }
          }
        }

        run_test!
      end
    end

    post '创建浮动薪金每月设定' do
      tags '浮动薪金设定'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :year_month, in: :query, type: :string, required: true, description: '创建年月 YYYY/MM'

      response '201', '创建成功' do
        run_test!
      end

      response '409', '当月的浮动薪金条目已经存在' do
        run_test!
      end
    end

  end

  path '/float_salary_month_entries/{id}/show_for_search' do
    get '列表页查询浮动薪金月表状态' do
      tags '浮动薪金设定'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true, description: '浮动薪金月份条目的ID'

      response '200', '獲取成功' do
        run_test!
      end

    end
  end

  path '/float_salary_month_entries/{id}' do
    patch '更新浮动薪金月表状态' do
      tags '浮动薪金设定'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true, description: '浮动薪金月份条目的ID'
      parameter name: :status, in: :query, type: :string, required: true, description: '更新浮动薪金状态, not_approved / approved'

      response '200', '更新成功' do
        run_test!
      end

      response '422', '更新失败' do
        run_test!
      end
    end

    delete '删除浮动薪金月表' do
      tags '浮动薪金设定'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true, description: '浮动薪金月份条目的ID'

      response '200', '删除成功' do
        run_test!
      end
    end
  end

  path '/float_salary_month_entries/year_month_options' do
    get '获取浮动薪金月份下拉选项' do
      tags '浮动薪金设定'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        schema type: :array, items: { type: :string, description: '年月 YYYY/MM' }
        run_test!
      end
    end
  end

  path '/float_salary_month_entries/approved_year_month_options' do
    get '获取已审批浮动薪金月份下拉选项' do
      tags '浮动薪金设定'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        schema type: :array, items: { type: :string, description: '年月' }
        run_test!
      end
    end
  end

  path '/float_salary_month_entries/check' do
    get '检查是否已经存在当月浮动薪金月表' do
      tags '浮动薪金设定'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :year_month, in: :query, type: :string, required: true, description: '需要查询的年月  YYYY/MM'

      response '200', '请求成功' do
        schema type: :object, properties: { data: { type: :boolean } }
        run_test!
      end
    end
  end

  path '/float_salary_month_entries/{id}/bonus_element_items' do
    post '创建当月浮动薪金每个成员的浮动薪金数据(下一步)' do
      tags '浮动薪金设定'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true, description: '浮动薪金月份条目的ID'

      response '400', '错误的请求ID' do
        run_test!
      end

      response '200', '请求成功' do
        schema type: :object, properties: { success: { type: :boolean } }
        run_test!
      end

    end
  end

  path '/float_salary_month_entries/{id}/import_amounts' do
    post '汇入浮动薪金每份金额数据' do
      tags '浮动薪金设定'
      consumes 'multipart/form-data'
      parameter name: :file, in: :formData, type: :file, description: '上传的文件'
      parameter name: :id, in: :path, type: :integer, required: true, description: '浮动薪金月份条目的ID'

      response '201', '导入成功' do
        schema type: :object, properties: { success: { type: :boolean } }
        run_test!
      end
    end
  end

  path '/float_salary_month_entries/{id}/import_bonus_element_items' do
    post '汇入浮动薪金个人数据数据' do
      tags '浮动薪金设定'
      consumes 'multipart/form-data'
      parameter name: :file, in: :formData, type: :file, description: '上传的文件'
      parameter name: :id, in: :path, type: :integer, required: true, description: '浮动薪金月份条目的ID'

      response '201', '导入成功' do
        schema type: :object, properties: { success: { type: :boolean } }
        run_test!
      end
    end
  end

  path '/float_salary_month_entries/{id}/export_amounts' do

    get '汇出浮动薪金每份金额数据' do
      tags '浮动薪金设定'
      consumes 'application/json'
      produces 'application/xlsx'
      parameter name: :id, in: :path, type: :integer, required: true, description: '浮动薪金月份条目的ID'

      response '200', '汇出成功' do
        run_test!
      end
    end
  end

end