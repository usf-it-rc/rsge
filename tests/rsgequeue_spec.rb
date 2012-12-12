# rsgequeue_spec.rb

require 'rsgequeue'

queues = RsgeQueue.new

queues.each do |queue|
    puts queue.name.to_s + " " + queue.used.to_s + " " + queue.avail.to_s + " " + queue.total.to_s
end
