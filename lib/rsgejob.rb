require 'rsgereq'
require 'time'
require 'rexml/document'
require 'nokogiri'
require 'rsgejobs'
include REXML

class Rsgejob < Rsgejobs

    def initialize(jobid)
        @job = @@jobs[jobid]
        @jobHr = @@jobsHr[jobid]
        @jobSr = @@jobsSr[jobid]
    end

    # Accessor methods
    def jobid
        @job[:jobid]
    end

    def slots
        @job[:slots]
    end

    def subTime
        @job[:submission_time]
    end 

    def startTime
        @job[:start_time]
    end 

    def queue_name
        @job[:qname]
    end

    def hard_req_queue
        @job[:hqueue]
    end

    def state
        @job[:state]
    end

    def owner
        @job[:job_owner]
    end 

    def hard_request_list
        @jobHr.keys.sort
    end 

    def hard_request(cplx)
        @jobHr[cplx]
    end 
   
    def soft_request_list
        @jobSr.keys.sort
    end 

    def soft_request(cplx)
        @jobSr[cplx]
    end 

end
