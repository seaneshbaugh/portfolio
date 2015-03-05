module RabbitmqJobProcessor
  class Worker
    @logger = nil

    def self.logger
      @logger
    end

    def self.logger=(new_logger)
      @logger = new_logger
    end

    def self.reload_app?
      defined?(ActionDispatch::Reloader) && Rails.application.config.cache_classes == false
    end

    def initialize(options = {})
      @queue_names = options[:queues]
    end

    def logger
      self.class.logger
    end

    def say(text, level = 'info')
      puts text

      return unless logger

      self.class.logger.send(level, text)
    end

    def start
      trap('TERM') do
        Thread.new { say 'Exiting...' }

        stop
      end

      trap('INT') do
        Thread.new { say 'Exiting...' }

        stop
      end

      say 'Worker started.'

      begin
        @connection = Bunny.new(Rails.configuration.rabbitmq_connection_settings)

        @connection.start

        @channel = @connection.create_channel

        @queues = []

        @queue_names.each do |queue_name|
          queue = @channel.queue(queue_name, auto_delete: true, durable: true)

          queue.subscribe do |delivery_info, metadata, payload|
            begin
              parsed_payload = JSON.parse(payload)

              say "Recieved job #{parsed_payload['job_id']} for \"#{parsed_payload['queue_name']}\". Job Class: #{parsed_payload['job_class']}. Arguments: #{parsed_payload['arguments']}"

              job = parsed_payload['job_class'].constantize.new

              job.perform(parsed_payload['arguments'].first)

              say "Finished processing job #{parsed_payload['job_id']} for \"#{parsed_payload['queue_name']}\"."
            rescue => exception
              say "#{exception.message}\n#{exception.backtrace.join("\n")}", 'error'
            end
          end

          @queues << queue
        end
      rescue => exception
        say "#{exception.message}\n#{exception.backtrace.join("\n")}", 'error'

        raise exception
      end

      loop do
        break if stop?

        sleep 5
      end
    end

    def stop
      @connection.close if @connection

      @exit = true
    end

    def stop?
      !!@exit
    end

    private

    def reload!
      return unless self.class.reload_app?

      ActionDispatch::Reloader.cleanup!

      ActionDispatch::Reloader.prepare!
    end
  end
end
