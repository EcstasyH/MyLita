#---
# Excerpted from "Build Chatbot Interactions",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/dpchat for more book information.
#---
require "spec_helper"

describe Lita::Handlers::SmtpMailer, lita_handler: true do
  let(:robot) { Lita::Robot.new(registry) }

  subject { described_class.new(robot) }

  describe ':send_email' do
    it { is_expected.to route("Lita email dpritchett@gmail.com Hi daniel from lita tests") }
    it { is_expected.to route("Lita email 765695900@qq.com hello") }
    it { is_expected.to route("Lita email daniel@localhost hello") }

    it { is_expected.to_not route("Lita email daniel") }
    it { is_expected.to_not route("Lita email dpritchett@gmail.com") }

    it 'emails numbers' do
      send_message 'Lita email dpritchett@gmail.com Hi daniel from lita tests'
      expect(replies.last.include?('dpritchett@gmail.com')).to be_truthy
    end
  end


end
