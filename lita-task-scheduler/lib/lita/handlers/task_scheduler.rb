#---
# Excerpted from "Build Chatbot Interactions",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/dpchat for more book information.
#---
require 'lita/scheduler'

module Lita
  module Handlers
    class TaskScheduler < Handler
      
      route(/^remind\sme\sof\s(\d+)\sin\s(.+)$/i, :remind_command, command: true)
      route(/^remind\sme\sby\semail\sof\s(\d+)\sin\s(.+)$/i, :remind_command_by_email, command: true)
      route(/^repeat\s+(.+)$/, :repeat_command, command: true)
      route(/^schedule\s+"(.+)"\s+in\s+(.+)$/i, :schedule_command, command: true)
      route(/^show schedule$/i, :show_schedule, command: true)
      route(/^empty schedule$/i, :empty_schedule, command: true)
      

      def repeat_command(payload)
        str = payload.matches.last
        payload.reply str
      end

      def show_schedule(payload)
        payload.reply schedule_report(scheduler.get_all)
      end

      def empty_schedule(payload)
        scheduler.clear
        show_schedule payload
      end

      def schedule_command(payload)
        task, timing = payload.matches.last
        run_at = parse_timing(timing)
        serialized = command_to_hash(payload.message, new_body: task)

        defer_task(serialized, run_at)
        show_schedule payload
      end


      def remind_command(payload)
        lecture_id, timing = payload.matches.last
        run_at = parse_timing(timing)
        
        name = find_lecture_name_in_db(lecture_id)
        if !name.is_a?(String)
          payload.reply "Could not find the lecture."
          return
        end
        task = "repeat It is time for #{name}" 
        serialized = command_to_hash(payload.message, new_body: task)
        defer_task(serialized, run_at)

        show_schedule payload
      end

      def remind_command_by_email(payload)
        lecture_id, timing = payload.matches.last
        run_at = parse_timing(timing)
        
        name = find_lecture_name_in_db(lecture_id)
        if !name.is_a?(String)
          payload.reply "Could not find the lecture."
          return
        end
        #user = command_hash.fetch('user_name')
        user = "765695900@qq.com"
        task = "email #{user} It's time for lecture#{name}" 
        serialized = command_to_hash(payload.message, new_body: task)
        defer_task(serialized, run_at)

        show_schedule payload
      end

      def find_lecture_name_in_db(id)
        id.to_i
        db = SQLite3::Database.open "development.sqlite3"
        rs = db.execute "SELECT * FROM lectures WHERE Id=#{id.to_i}"
        db.close 
        rs.to_s
      end

      def scheduler
        @_schedule ||= Scheduler.new(redis: redis, logger: Lita.logger)
      end

      def schedule_report(schedule)
        descriptions = []

        schedule.keys.each do |timestamp|
          play_time = Time.at(timestamp.to_i)
          tasks_json = schedule[timestamp]
          tasks = JSON.parse(tasks_json)

          tasks.each do |task|
            descriptions << "\n - \"#{task.fetch('body')}\" at #{play_time}"
          end
        end

        'Scheduled tasks: ' + (descriptions.empty? ? 'None.' : descriptions.join)
      end

      def defer_task(serialized_task, run_at)
        scheduler.add(serialized_task, run_at)
      end

      def parse_timing(timing)
        count, unit = timing.split
        count = count.to_i
        unit = unit.downcase.strip.gsub(/s$/, '')

        seconds = case unit
                  when 'second'
                    count
                  when 'minute'
                    count * 60
                  when 'hour'
                    count * 60 * 60
                  when 'day'
                    count * 60 * 60 * 24
                  else
                    raise ArgumentError, "I don't recognize #{unit}"
                  end

        Time.now.utc + seconds
      end

      def resend_command(command_hash)
        user = Lita::User.new(command_hash.fetch('user_name'))
        room = Lita::Room.new(command_hash.fetch('room_name'))
        source = Lita::Source.new(user: user, room: room)
        body = "#{robot.name} #{command_hash.fetch('body')}"

        newmsg = Lita::Message.new(
          robot,
          body,
          source
        )

        robot.receive newmsg
      end

      def command_to_hash(command, new_body: nil)
        {
          user_name: command.user.name,
          room_name: command.source.room,
          body: new_body || command.body
        }
      end

      def find_tasks_due
        scheduler.find_tasks_due
      end

      def run_loop
        Thread.new do
          loop do
            tick
            sleep 1
          end
        end
      end

      def tick
        tasks = find_tasks_due
        tasks.each { |t| resend_command t }
        Lita.logger.debug "Task loop done for #{Time.now}"
      end

      on(:loaded) { run_loop }

      Lita.register_handler(self)
    end
  end
end
