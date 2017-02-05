module BlocWorks
  class Application
    def root(env)
      if env['PATH_INFO'] == '/'
        return [200, {'Content-Type' => 'text/html'}, ["Hello Blocheads!"]]
      end
    end
    def controller_and_action(env)
      _, controller, action, _ = env["PATH_INFO"].split("/", 4)
      controller = controller.capitalize
      controller = "#{controller}Controller"

      [Object.const_get(controller), action]
    end

    def fav_icon(env)
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, []]
      end
    end

    def route(&block)
      @router ||= Router.new
      @router.instance_eval(&block)
    end

    def get_rack_app(env)
      if @router.nil?
        raise "No routes defined"
      end
      @router.look_up_url(env["PATH_INFO"])
    end
  end

  class Router
    def initialize
      @rules = []
    end

    def map(url, *args)
      options = option_setter(args)
      destination = destination_setter(args)

      parts = url.split("/")
      parts.reject! { |part| part.empty? }
      handled_parts = parts_handler(parts)

      regex = handled_parts[1].join("/")
      @rules.push({ regex: Regexp.new("^/#{regex}$"),
                    vars: handled_parts[0], destination: destination,
                    options: options })
    end

    def look_up_url(url)
      rule = @rules.select{|x| x[:regex].match(url)}.first
      rule_match = rule[:regex].match(url)
      options = rule[:options]
      params = options[:default].dup

      rule[:vars].each_with_index do |var, index|
        params[var] = rule_match.captures[index]
      end

      x = rule[:destination] ? rule[:destination] : "#{params["controller"]}##{params["action"]}"
      return get_destination(x, params)
    end

    def resources(controller)
      map ":controller/:id", default: { "action" => "show" }
      map ":controller", default: { "action" => "index" }
      map ":controller", default: { "action" => "new" }
      map ":controller/:id", default: { "action" => "edit" }
      map ":controller/:id", default: { "action" => "update" }
      map ":controller", default: { "action" => "create" }
      map ":controller/:id", default: { "action" => "destroy" }
    end

    def get_destination(destination, routing_params = {})
      if destination.respond_to?(:call)
        return destination
      end
      if destination =~ /^([^#]+)#([^#]+)$/
        name = $1.capitalize
        controller = Object.const_get("#{name}Controller")
        return controller.action($2, routing_params)
      end
      raise "Destination not found: #{destination}"
    end

    private

    def option_setter(argArray)
      options = {}
      options = argArray.pop if argArray[-1].is_a?(Hash)
      options[:default] ||= {}
      options
    end

    def destination_setter(args)
      destination = nil
      destination = args.pop if args.size > 0
      raise "Too many args!" if args.size > 0
      return destination
    end

    def parts_handler(parts)
      vars, regex_parts = [], []
      parts.each do |part|
        case part[0]
        when ":"
          vars << part[1..-1]
          regex_parts << "([a-zA-Z0-9]+)"
        when "*"
          vars << part[1..-1]
          regex_parts << "(.*)"
        else
          regex_parts << part
        end
      end
      return [vars, regex_parts]
    end

  end
end
