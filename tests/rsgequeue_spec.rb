# rsgequeue_spec.rb

require 'rsgequeue'

$rspec_init = true

describe RsgeQueue do
    before :all do
        @queues = RsgeQueue.new
    end

    it "returns a list of queues" do
        @queues.list.should eql([:default, :xlong])
    end
end

#queues.each do |queue|
#    puts queue.name.to_s + " " + queue.used.to_s + " " + queue.avail.to_s + " " + queue.total.to_s
#end
# rsgejob_spec.rb
