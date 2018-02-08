class Config
  @config_path = nil
  class << self
    attr_accessor :config_path

    def get(key, default=nil)
      Rails.cache.fetch(['config', key]) do
        yaml_path = self.get_config_path
                        .map { |path| File.join path, self.get_config_file_name(key) }
                        .find { |file_path| File.exists? file_path }
        options = {}
        Dir[Rails.root.join('config', 'predefined', key.to_s, '**', '*.yml')].each { |path| options.merge!( YAML.load_file(path) ) }
        begin
          YAML.load_file(yaml_path).merge(options)
        rescue StandardError => ex
          options
        end
      end
    end

    def set_config_path(path)
      self.config_path = path
    end

    def get_config_path
      root_config_path = File.join(Rails.root, 'config')
      config_paths = [root_config_path, File.join(root_config_path, 'predefined')]
      config_paths.unshift(self.config_path) if self.config_path
      config_paths
    end

    def get_config_file_name(key)
      "#{key.to_s}.yml"
    end

    def get_option_from_selects(column,keys)
      Config.get(:selects)[column.to_s]['options'].select{|item| keys.include? item['key']}
    end

    def get_all_option_from_selects(column)
      Config.get(:selects)[column.to_s]['options']
    end

    def get_single_option(column, key)
      Config.get(:selects)[column.to_s]['options'].select{|item| key == item['key']}.first
    end
  end
end
