class FigaroYamlParser
  FILE_PATH = File.join(Rails.root, 'config', 'application.yml')
  FIGARO_YAML = YAML::load(IO.read(FILE_PATH))

  def parse(yaml_data = FIGARO_YAML)
    yaml_data.each do |key, value|
      if value.is_a?(Hash)
        parse(value)
      elsif value == 'yes' || value == 'no'
        raise %q(
          You set #{key} to #{value} in config/application.yml.
          Please change it to true or false
        )
      end
    end
  end
end
