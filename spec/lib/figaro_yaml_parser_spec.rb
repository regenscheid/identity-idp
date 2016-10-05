require 'rails_helper'

describe FigaroYamlParser do
  describe '#parse' do
    it 'raises if a value is set to yes' do
      yaml = FigaroYamlParser::FIGARO_YAML
      test_key = 'test_key'
      bad_yaml = yaml.merge(test_key => 'yes')

      expect { FigaroYamlParser.new.parse(bad_yaml) }.to raise_error(RuntimeError)
    end

    it 'raises if a value is set to no' do
      yaml = FigaroYamlParser::FIGARO_YAML
      test_key = 'test_key'
      bad_yaml = yaml.merge(test_key => 'no')

      expect { FigaroYamlParser.new.parse(bad_yaml) }.to raise_error(RuntimeError)
    end
  end
end
