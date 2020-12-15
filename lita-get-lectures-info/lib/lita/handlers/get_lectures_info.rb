require 'net/http'

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
        # 工头函数
        @login_page = 'http://sep.ucas.ac.cn/'
        @receice_page = 'http://sep.ucas.ac.cn/msg/receive/list'
        @msg=[]
        
        chromedriver_path = File.join(File.absolute_path('./', File.dirname(__FILE__)),'chromedriver')
        #chromedriver_path = File.join(File.absolute_path('/Users/wuhao/Download/', File.dirname(__FILE__)),'chromedriver')
        
        Selenium::WebDriver::Chrome::Service.driver_path = chromedriver_path
        @browser = Selenium::WebDriver.for :chrome
        sleep(3)
        #
        get_list
        @browser.quit
        # 框架使用这一行返回
        # 用这个函数返回前端就能收到了
        response.reply @msg
      end

      

      def get_cookie
        # 
        @browser.navigate.to @login_page
        #elem_user = @browser.find_elements(:xpath, '//input[@id="userName"]')
        #elem_user.send_keys('maxiaohan20@mails.ucas.ac.cn')
        #elem_pwd = @browser.find_elements(:xpath, '//input[@type="password"]')
        #elem_pwd.send_keys('msqmf997')
        
        sleep(20)
        #wuhao164@mails.ucas.ac.cn 
        #wh17771411015
        #commit = browser.find_element_by_xpath('//button[@type="submit"]')
        #commit.click
      end

      

      def get_list
        #
        get_cookie

        @browser.navigate.to @receice_page
        doc = Nokogiri::HTML(@browser.page_source)
        
        # 点不止一下，如何分开处理
        # 得了吧，因为网页刷新时会无法继续find element，这方法不奏效
        # notices = @browser.find_elements_by_xpath --python 写法

        #
        notices = []
        notice = @browser.find_elements(:xpath, "//a[contains(@href,'receiverShow') and contains(text(),'关于科学前沿讲座的通知')]")  
        notice.each {|element| notices.append(@login_page + element["href"]) }


        notices.each do |url|
          puts url.class
          @browser.navigate.to url
          doc_sub = Nokogiri::HTML(@browser.page_source)
          sleep(10)
          parse_list(doc_sub)
        end

        # 测试用的没用的话
        ll = []
        ll = notices

      end


      def parse_list(doc)
        # 根据位置
        table = doc.xpath("//td")
        list = []
        table.each { |e| list.append(e.text) }
        list.drop(9)
        @msg += list
      end

      
      Lita.register_handler(self)
    end
  end
end
