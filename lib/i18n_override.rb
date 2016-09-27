require 'i18n'

I18n.module_eval do
  class << self
    def translate_with_markup(*args)
      i18n_text = normal_translate(*args)
      return i18n_text unless FeatureManagement.enable_dev_mode? && i18n_text.is_a?(String)

      key = args.first.to_s
      rtn = i18n_text + additional_markup(key)

      rtn.html_safe
    end

    private

    def find_line_number(file, key)
      spaces = 2 * key.split('.').length
      last_key = key.split('.').last

      match_str = ' ' * spaces
      match_str += last_key + ':'

      match_with_value = match_str + ' ' + I18n.t(key)
      match_with_multiline = match_str + ' >'
      match_with_quotes = match_str + ' "' + I18n.t(key)

      # the i18n module does not maintain references to the source of a
      # translation, therefore, we are parsing and searching each instance
      # of a localized file to find the source of the translation.
      # this could most-certainly be improved :)
      line_num = File.foreach(file).with_index do |line, i|
        if line =~ /#{match_with_value}|#{match_with_multiline}|#{match_with_quotes}/
          break i + 1
        end
      end
      line_num
    end

    def additional_markup(key)
      uri = get_loc_uri(key)
      return '' unless uri

      "<a href=\"#{uri}\" target=\"_blank\" class=\"i18n-trans-link\">🔗</a>"
    end

    def get_loc_uri(key)
      file = find_key(key)

      return nil unless file

      base_uri = 'https://github.com/18F/identity-idp/tree/master/config/locales/'
      base_uri + file.split('/').last + '#L' + find_line_number(file, key).to_s
    end

    def i18n_files
      Dir[Rails.root.join('config', 'locales', '*.{yml}').to_s]
    end

    def find_key(key)
      i18n_files.each do |file|
        location = traverse_file_for_key(file, key)
        return location if location
      end
      nil
    end

    def traverse_file_for_key(file, key)
      yml = YAML.load(File.open(file))[I18n.config.locale.to_s]
      send_string = ''

      elements = key.split('.')
      elements.each_with_index do |e, _i|
        send_string += "['#{e}']"
      end

      begin
        str = eval("yml#{send_string}")
        return file if str
      rescue NoMethodError
        return
      end
    end

    alias_method :normal_translate, :translate
    alias_method :translate, :translate_with_markup
  end
end
