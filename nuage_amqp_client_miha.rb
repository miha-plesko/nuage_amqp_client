#--
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#++

require 'qpid_proton'
require 'optparse'
require 'json'

class NuageMB < Qpid::Proton::Handler::MessagingHandler

  def initialize(url, topics, opts)
    super()
    @url = url
    @topics = topics
    @opts = opts
    @test_connection = @opts.delete(:test_connection)
    @message_handler_block = @opts.delete(:message_handler_block)
  end

  def on_start(event)
    event.container.container_id = "Ruby AMQP"
    conn = event.container.connect(@url, @opts)
    @topics.each { |topic| event.container.create_receiver(conn, :source => "topic://#{topic}") }
    puts "started"
  end

  def on_connection_opened(event)
#    super
    puts "opened"
    event.container.stop if @test_connection
  end

  def on_connection_closed(event)
    puts "closed"
  end

  def on_connection_error(event)
    raise StandardError, "Connection error"
  end

  def on_message(event)
    message = JSON.parse(event.message.body)
    event_type = "#{message['entityType']}_#{message['type'].downcase}"
    print("--- [00] on_message: #{event_type}\n")
    @message_handler_block.call(JSON.parse(event.message.body))
  end

  def on_transport_error(event)
    raise StandardError, "Connection error: #{event.transport.condition}"
  end
end



#
#
#

@queue = Queue.new
@batch = Queue.new

def start_batch
  print("start_batch\n")
  @thread = qpid_thread
  # @thread = qpid_thread_mock

  print("created thread\n")
  while @thread.alive? || !@batch.empty?
    sleep(5)
    print("\n[01] yield batch with count=#{@batch.size}\n") unless @batch.empty?
    yield current_batch, Time.now unless @batch.empty?
  end
  print("thread not running anymore #{@thread}\n")
end

def qpid_thread
  options = {
    :sasl_allowed_mechs        => "PLAIN",
    :sasl_allow_insecure_mechs => true,
    :test_connection           => false,

    :message_handler_block     => ->(event) { @batch << event }
  }
  Thread.new do
    begin
      endpoint = ENV['NUAGE_AMQP']
      topics = ["topic/CNAMessages", "topic/CNAAlarms"]

      print("endpoint: #{endpoint}\n")
      print("endpoint: #{topics}\n")
      print("endpoint: #{options}\n")

      handler = NuageMB.new(endpoint, topics, options)
      connection = Qpid::Proton::Reactor::Container.new(handler)
      connection.run do |arg|
        print("BUREK: #{arg}\n")
        sleep(0)
      end
    rescue => e
      print("Error in thread: #{e}\n")
    end
  end
end

def qpid_thread_mock
  Thread.new do
    i = 0
    loop do
      l = ->(event) { @batch << event }
      e = {
        :mock => "mock-#{i}"
      }

      l.call(e)
      print("--- [00 mock event]\n")
      i += 1
      sleep(0.1)
    end
  end
end

def current_batch
  Array.new(@batch.size) { @batch.pop }
end

def parser_thread
  Thread.new do
    loop do
      while !@queue.empty? do
        event = @queue.deq()
        print("[03] Parsed events count = #{event.count}\n") if event
      end
      sleep(0.1)
    end
  end
end

#
# MAIN
#

parser_thread
start_batch do |events, timer|
  now = Time.now
  print("[02] ADD TO QUEUE count=#{events.size}, time since yielding batch = #{(now - timer).round(2)}s\n")

  @queue.enq(events)
end
