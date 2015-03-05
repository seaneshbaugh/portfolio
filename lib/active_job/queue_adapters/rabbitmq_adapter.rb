module ActiveJob
  module QueueAdapters
    class RabbitmqAdapter
      class << self
        def enqueue(job)
          connection = Bunny.new(Rails.configuration.rabbitmq_connection_settings)

          connection.start

          channel = connection.create_channel

          queue = channel.queue(job.queue_name, auto_delete: true, durable: true)

          exchange = channel.default_exchange

          exchange.publish(job.serialize.to_json, routing_key: queue.name)
        end

        def enqueue_at(job)
          fail NotImplementedError
        end
      end
    end
  end
end
