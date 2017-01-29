require "erubis"

module BlocWorks
  class Controller

    def initialize(env)
      @env = env
      @routing_params = {}
    end

    def dispatch(action, routing_params = {})
      @routing_params = routing_params
      text = self.send(action)
      if has_response?
        rack_response = get_response
        [rack_response.status, rack_response.header, [rack_response.body].flatten]
      else
        response(create_response_array(action))
      end
    end

    def self.action(action, response = {})
      proc { |env| self.new(env).dispatch(action, response)}
    end

    def request
      @request ||= Rack::Request.new(@env)
    end

    def params
      request.params.merge(@routing_params)
    end

    def response(text, status = 200, headers = {})
      raise "Cannot respond multiple times" unless @response.nil?
      @response = Rack::Response.new([text].flatten, status, headers)
    end

    def render(*args)
      response(create_response_array(*args))
    end

    def redirect(*args)
      response(create_response_array(*args), 302)
    end

    def get_response
      @response
    end

    def has_response?
      !@response.nil?
    end

    def create_response_array(view, locals= {})
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
