require 'mechanize'

agent = Mechanize.new
page = agent.get('http://sep.ucas.ac.cn/')
login_form = page.forms.first
login_form.userName = 'maxiaohan20@mails.ucas.ac.cn'
login_form.pwd = 'msqmf997'
page = agent.submit(login_form, login_form.buttons.first)
# pp page
# success
receice_page = 'http://sep.ucas.ac.cn/msg/receive/list'
page_rec = agent.get(receice_page)
# pp page_rec
# success
nodeset = page_rec.search("//a[contains(@href,'receiverShow') and contains(text(),'关于科学前沿讲座的通知')]/@href")
urls = []
nodeset.each {|element| urls.append(element.value)}
urls.map! { |e| 'http://sep.ucas.ac.cn' + e }
# puts urls
# success

msg = []
tmp = 1
urls.each do |url|
    html = agent.get(url)
    table = html.search("td")
    list = []
    table.each { |e| list.append(e.text) }
    
    list = list.drop(9)
    if (list != tmp)
       msg += list
    end
    tmp = list
end

i = 0
while (msg[i]) do
    if msg[i].include?("2020")
        msg.insert(i+2,"=========================")
    end
    i=i+1
end

puts msg