require 'mechanize'
require 'sqlite3'

module Lita
  module Handlers
    class GetLecturesInfo < Handler
      # insert handler code here
      route(
        /lectures$/i,
        :respond_with_lecture,
        command:true,
        help:{ 'show me new lectures' => 'print new lecture info' }
      )


      def respond_with_lecture(response)
        # top level
        @login_page = 'http://sep.ucas.ac.cn/'
        @receice_page = 'http://sep.ucas.ac.cn/msg/receive/list'
        @agent = Mechanize.new
        @msg = []
        #
        get_cookie#(userName, pwd)
        get_list
        parse_list
        #
        response.reply @output
      end

      

      def get_cookie#(userName, pwd)
        # aim to get agent with cookie
        page = @agent.get(@login_page)
        login_form = page.forms.first
        login_form.userName = 'maxiaohan20@mails.ucas.ac.cn'
        login_form.pwd = 'msqmf997'
        page = @agent.submit(login_form, login_form.buttons.first)
      end

      

      def get_list
        #
        @page_rec = @agent.get(@receice_page)
      end


      def parse_list
        # 
        nodeset = @page_rec.search("//a[contains(@href,'receiverShow') and contains(text(),'关于科学前沿讲座的通知')]/@href")
        urls = []
        nodeset.each {|element| urls.append(element.value)}
        urls.map! { |e| 'http://sep.ucas.ac.cn' + e }
        #
        tmp = 1
        urls.each do |url|
          html = @agent.get(url)
          table = html.search("td")
          list = []
          table.each { |e| list.append(e.text) }
          list = list.drop(9)

          if tmp != list
            @msg += list
          end
          tmp = list
        end
        
        write_in_db

      end

      def write_in_db
        db = SQLite3::Database.open "development.sqlite3"

        rs = db.execute "SELECT * FROM lectures" 
        
        @output =[]

        if !rs.last
          new_id = 1
        else 
          new_id = rs.last[0]+1
        end
        i=0
        while(@msg[4*i]) do
          db.execute "INSERT INTO Lectures VALUES('#{i+new_id}','#{@msg[4*i]}','#{@msg[4*i+1]}','#{@msg[4*i+2]}','#{@msg[4*i+3]}')"
          @output << (i+new_id).to_s
          @output << @msg[4*i]
          @output << @msg[4*i+1]
          @output << @msg[4*i+2]
          @output << @msg[4*i+3]
          i=i+1
        end 
        #@output = @output.to_s
        db.close
      end

      Lita.register_handler(self)
    end
  end
end
