require 'net/smtp'

to_address = "765695900@qq.com"
message_body = "hello"

message = <<MESSAGE_END
From: Private Person <railschatbot@126.com>
To: A Test User <765695900@qq.com>
Subject: SMTP e-mail test

#{message_body}
MESSAGE_END



Net::SMTP.start('smtp.126.com', 
                25, 
                'localhost', 
                'railschatbot@126.com', 'EMKQUONJQSVGEFES' ,:plain) do |smtp|
                    smtp.send_message message, 'railschatbot@126.com', to_address
                end

#email 765695900@qq.com hello