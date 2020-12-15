require "spec_helper"
require 'pry'

describe Lita::Handlers::GetLecturesInfo, lita_handler: true do
  let(:robot) { Lita::Robot.new(registry) }

  subject { described_class.new(robot) }


  describe 'routes' do
    # confirm three variations on what's brad eating each trigger a response
    it { is_expected.to route("Lita show me new lectures") }
    it { is_expected.to route("Lita Show me LECTURES") }
    it { is_expected.to route("Lita shows lectures") }
  end


  # validate navigability of parsed web content
  describe ':get_cookie' do
    # it 是如果这里卡bug 会被输出的日志
    it 'should return a driver object with a find_elements method' do
      expect(subject.get_cookie).to respond_to(:find_elements(:xpath, '//input[@id="userName"]'))

      commit = subject.get_cookie.find_element_by_xpath('//button[@type="submit"]')
      expect(commit).to respond_to(:click)
    end
  end


  # validate your basic HTML content fetching methods
  describe ':get_list' do
    let(:body) { subject.get_list }


    it "any url in the list should contains some same string" do
      expect(body[0] =~ /ucas/i).to be_truthy
    end


    it 'any url in the list should contains some same string' do
      expect(body[-1] =~ /msg/i).to be_truthy
    end

  end


  # validate navigability of parsed web content
  describe ':parse_list' do
    it 'lectures info consist of four items, last but one should be time item' do
      expect(subject.parse_list.match(/\d{4}\-\d{2}\-\d{2} \d{2}\:\d{2}\-\d{2}\:\d{2}/i))
      
    end
  end



  # high-level "lita hears X and returns Y" end-to-end testing
  describe ':respond_with_lecture' do
    it 'responds with a list of info items' do
      send_message "Lita show me new lectures"
      expect(replies[-2].match(/\d{4}\-\d{2}\-\d{2} \d{2}\:\d{2}\-\d{2}\:\d{2}/i))
    end
  end

end
