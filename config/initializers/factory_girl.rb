if Rails.env.development? || Rails.env.test?
  FactoryGirl.definition_file_paths.delete(File.join(Rails.root, 'spec/factories'))
end
