require "erubis"

module BlocWorks
  class Controller
    def initialize(env)
      @env = env
    end

    def render(view, locals = {})
      filename = File.join("app", "views", controller_dir, "#{view}.html.erb")
      template = File.read(filename)
      eruby = Erubis::Eruby.new(template)
      self.instance_variables.each do |inst_var|
        inst_var_value = self.instance_variable_get(inst_var)
        eruby.instance_variable_set(inst_var, inst_var_value)
      end
      eruby.result(locals.merge(env: @env))
    end

    def controller_dir
      klass = self.class.to_s
      klass.slice!("Controller")
      BlocWorks.snake_case(klass)
    end
  end
end
