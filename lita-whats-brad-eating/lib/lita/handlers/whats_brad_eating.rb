module Lita
  module Handlers
    class WhatsBradEating < Handler
      route /^what is brad eating$/i,
        :brad_eats,  #handler name
        command: true, # handle this as a direct command
        help: {
          "what is brad eating" => "latest post from brad's food tumblr"
        }

      def brad_eats(response)
        response.reply 'Actual results coming soon!'
      end

      BLOG_URL = 'https://weibo.com/u/6365432889'.freeze

      def response
        @_response ||= http.get(BLOG_URL)
      end
      Lita.register_handler(self)
    end
  end
end
