require "spec_helper"

describe Lita::Handlers::WhatsBradEating, lita_handler: true do
    describe 'routes' do
        it {is_expected.to route("Lita what is brad eating")}
        it {is_expected.to route("Lita What is BRAD eating")}

        it {is_expected.to_not route("lita what's brad eating")}
    end 
    ## but don't know how to test 

    describe ':response' do 
        let(:body){ subject.response.body}

        it "should be able to pull down some HTML from Brad's blog" do
            expect(body =~ /<html>/i).to be_truthy
        end
        it 'should include something that looks like an image tag' do
            expect(body =~ /img src/i).to be_truthy
        end
        #it 'should include a caption' do
            #xpect(body.include?('caption')).to be_truthy
        #end
        end
end
