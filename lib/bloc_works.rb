require "bloc_works/version"
require "bloc_works/controller"
require "bloc_works/utility"
require "bloc_works/router"
require "bloc_works/dependencies"

module BlocWorks
  class Application
    def call(env)
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, []]
      end
      rack_app = get_rack_app(env)
      rack_app.call(env)
    end
  end
end
