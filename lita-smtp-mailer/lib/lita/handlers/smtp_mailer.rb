#---
# Excerpted from "Build Chatbot Interactions",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/dpchat for more book information.
#---
require 'mail'
require 'pry'
require 'net/smtp'


module Lita
  module Handlers
    class SmtpMailer < Handler
      Lita.register_handler(self)

      SIMPLE_EMAIL_REGEX = /\S+@\S+/

      route /^email\s+(#{SIMPLE_EMAIL_REGEX})\s+(.+)$/i,
        :send_email,
        command: true,
        help: { 'email address@domain.com message body goes here' => 'Sends an email' }

      def send_email(response)
        to_address, message_body = response.matches.last
        message = <<MESSAGE_END
From: Private Person <railschatbot@126.com>
To: A Test User <765695900@qq.com>
Subject: RailsChatBot Scheduler

#{message_body}
MESSAGE_END

      Net::SMTP.start('smtp.126.com', 
                25, 
                'localhost', 
                'railschatbot@126.com', 'EMKQUONJQSVGEFES' ,:plain) do |smtp|
                    smtp.send_message message, 'railschatbot@126.com', to_address
                end
        
        response.reply "Sent email to [#{to_address}]."
      end

    end
  end
end
