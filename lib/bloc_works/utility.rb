module BlocWorks
  def self.snake_case(camel_case_word)
    string = camel_case_word.gsub(/::/, '/')
    string.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
    string.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    string.tr!("-", "_")
    string.downcase
  end
end
