module JsonResponseHelper
  def response_json(data = [], options = {}, &block)
    options[:error] ||= false
    options[:pagination] ||= false

    if options[:error]
      unless data.is_a? Array
        data = [data]
      end
      if options[:error] == 403
         res = {
            data: data,
            state: 'error'
        }
        code = 403
      else
        res = {
            data: data,
            state: 'error'
        }
        code = 422
      end
    else
      if options[:pagination]
        res = json_pagination_response_data(data, &block)
      else
        res = json_response_data(data)
      end
      code = 200
    end

    if options.key?(:meta)
      res[:meta] = options[:meta]
    end
    render :json => res, status: code, content_type: "application/json"
  end

  def response_json_error(error_code, detail=nil)
    error = Error.find(error_code)

    if detail
      error[:detail] = detail
    end

    response_json error, error: true
  end
  

  def json_response_data(data)
    {
        data: data,
        state: 'success'
    }
  end

  def json_pagination_response_data(data, &block)
    res = data
    if block_given?
      res = block.call(data)
    end

    {
      data: res,
      meta: {
        total_count: data.total_count,
        current_page: data.current_page,
        total_pages: data.total_pages
      },
      state: 'success'
    }
  end
end
