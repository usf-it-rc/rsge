# rsgejob_spec.rb

require 'rsgejob'

$rspec_init = true

describe RsgeJob do
    before :all do
        @jobs = RsgeJob.new
        @nonEnumJob = RsgeJob.new({ :enumerate => :job, :jobid => "79644" })
    end
    
    it "takes zero or one parameters and returns an RsgeJob object" do
        @jobs.should be_an_instance_of RsgeJob
        @nonEnumJob.should be_an_instance_of RsgeJob
    end

    it "returns full job list" do
        @jobs.list.count.should eql(985)
        @nonEnumJob.list.count.should eql(985)
    end

end

#classes.each do |myclass|
#    counts[myclass.to_sym] = 0
#end

#jobs.each do |job|
#
#    hr = job.hard_request_list
#
#    hr.each do |cplx| 
#        if (classes.include? cplx)
#            printf("%10s %3s %6s %16s %10s\n", job.jobid, job.state, job.slots, job.job_owner, cplx)
#            counts[cplx.to_sym] += 1
#        end
#    end
#end

#puts
#puts "    xlong = " + counts[:xlong].to_s + "  long = " + counts[:long].to_s + "  medium = " + counts[:medium].to_s + "  short = " + counts[:short].to_s 
#puts
# rsgehost_spec.rb
