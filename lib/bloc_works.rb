require "bloc_works/version"
require "bloc_works/controller"
require "bloc_works/utility"
require "bloc_works/router"
require "bloc_works/dependencies"

module BlocWorks
  class Application
    def call(env)
      response = self.root(env)

  		if response
  			return response
  		else
  			cont_array = self.controller_and_action(env)
  			cont = cont_array.first.new(env)
  			action_call = cont.send(cont_array.last)
  			return [200, {'Content-Type' => 'text/html'}, [action_call]]
  		end
    end
  end
end
