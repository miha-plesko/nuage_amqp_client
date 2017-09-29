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

class NuageMB < Qpid::Proton::Handler::MessagingHandler

  def initialize(url, topics, opts)
    super()
    @url = url
    @topics = topics
    @opts = opts
    @test_connection = @opts.delete(:test_connection)
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
    puts event.message.body
    #event.connection.close
  end

  def on_transport_error(event)
    raise StandardError, "Connection error: #{event.transport.condition}"
  end
end

options = {
  :sasl_allowed_mechs        => "PLAIN", 
  :sasl_allow_insecure_mechs => true,
  :test_connection           => false}

loop do
  begin
    hw = NuageMB.new(ENV['NUAGE_AMQP'],
        ["topic/CNAMessage", "topic/CNAAlarms"],
        options)
    Qpid::Proton::Reactor::Container.new(hw).run
  rescue => e
    puts "Caught exception #{e}"
  end

  sleep 2
end
