require 'yaml'
class CheckI18nMessage

  def self.equal?(key, language, text)
    translations = YAML.load_file(File.expand_path("../TestData/translations.yml", __FILE__))
    translations[language.to_s][key].eql? text
  end

end
