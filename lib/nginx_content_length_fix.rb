module Nginx
  class ContentLengthFix
    def initialize(app)
      @app = app       
    end                

    def call(env)
      status, headers, response = @app.call(env)
      headers["Content-Length"] = response.body.length.to_s if status == 201
      [ status, headers, response ]
    end                
  end
end
