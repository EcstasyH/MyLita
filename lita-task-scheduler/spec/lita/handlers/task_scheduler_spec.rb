require "spec_helper"

describe Lita::Handlers::TaskScheduler, lita_handler: true do
    describe 'routing' do 
        it {is_expected.to route('Lita schedule "double 4" in 2 hours')}
        it {is_expected.to route('Lita show schedule')}
        it {is_expected.to route('Lita empty schedule')}
    end

    describe ':defer_task' do
        it 'defers any single task' do
            message = {canary_message: Time.now}
            run_at = Time.now + 5 
            result = subject.defer_task(message, run_at)
            expect(result).to include(message)
        end

        it 'stores multiple same-second tasks in an array' do
            message = { 'canary_message' => Time.now.to_i }
            run_at = Time.now + 5
            5.times do
                subject.defer_task(message, run_at)
            end
                result = subject.defer_task(message, run_at)
                expect(result).to eq([message] * 6)
        end     
    end

    describe 'tick' do
        before { subject.stub(:find_tasks_due).and_return ['a_task'] }
        it 'should find tasks due and resend them' do
            expect(subject).to receive(:find_tasks_due)
            expect(subject).to receive(:resend_command).with('a_task')
            subject.tick
        end
    end

    describe ':find_tasks_due' do
        context 'two tasks are scheduled for five seconds ago' do
            before { 2.times { subject.defer_task('past_task', Time.now - 5) } }
            it 'returns all past due tasks' do
                result = subject.find_tasks_due
                expected = %w[past_task past_task]
                expect(result).to eq(expected)
            end
        end
    
        context 'one task scheduled in the future' do
            before { subject.defer_task('future_task', Time.now + 100) }
            
            it 'does not return that new task' do
                result = subject.find_tasks_due
                expect(result).to_not include('future_task')
            end
        end
    end
end
