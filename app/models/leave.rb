class Leave
  class << self
    def all
      [
        {
          key:  'personal_leave',
          chinese_name: '事假',
          english_name: 'Personal Leave'
        },
        {
          key: 'offical_leave',
          chinese_name: '公休',
          english_name: 'Offical Leave'
        },
        {
          key: 'annual_leave',
          chinese_name: '年假',
          english_name: 'Annual Leave',
        }
      ]
    end

    def find(key)
      all.find do |leave|
        leave[:key] == key
      end
    end
  end
end