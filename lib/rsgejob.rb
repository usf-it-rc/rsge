require 'rsgereq'
require 'time'
require 'rexml/document'
require 'rubygems'
require 'nokogiri'
require 'rsgejobs'
require 'rsgeutil'

# Provides methods for viewing GridEngine job information
class RsgeJob < RsgeJobs
    # no-brainer accessors
    attr_accessor :jobid, :job_name, :slots, :submission_time, :start_time, :queue,
                  :state, :job_owner, :pe, :pe_slots, :reservation, :cwd, :wd,
                  :hard_resreq, :soft_resreq, :joinout, :outfile, :errfile, :script,
                  :queue_name

    # In an 'overloaded' way, create the object based on whether an argument
    # is provided.  This will let us create either a base object with the current
    # job list or provide an object populated with a specific job's data
    def initialize(*args)
        extend RsgeUtil
        if (args[0] != nil)
            conf = args[0]
        else
            conf = Hash.new
        end

	    if (conf.class != Hash)
            raise ArgumentError, "Argument is not a hash! #{conf.class} #{conf}"
        end

        if conf.has_key?(:jobid)
            # We're providing a job and its info
            if (!defined?(@@jobs) or !defined?(@@jobsHr) or !defined?(@@jobsSr))
                RsgeJobs.new
            end

            job     = @@jobs[conf[:jobid]]
            jobhres = @@jobsHr[conf[:jobid]]
            jobsres = @@jobsSr[conf[:jobid]]

            self.jobid          = job[:jobid]
            self.job_owner      = job[:job_owner]
            self.job_name       = job[:job_name]
            self.queue          = job[:queue]
            self.queue_name     = job[:queue_name]
            self.reservation    = job[:reservation] 
            self.joinout        = job[:joinout]
            self.state          = job[:state]
            self.slots          = job[:slots]
            self.hard_resreq    = jobhres
            self.soft_resreq    = jobsres
            #self.pe = conf[:pe]                      if conf.has_key?(:pe)
            #self.pe_slots = conf[:pe_slots]          if conf.has_key?(:pe_slots)
            #self.script = conf[:script]              if conf.has_key?(:script)
            
            return self
        else
            # populate us
            self.job_owner = ENV['USER']
            self.job_name = conf[:job_name]          if conf.has_key?(:job_name)
            self.queue = conf[:queue]                if conf.has_key?(:queue)
            self.reservation = conf[:reservation]    if conf.has_key?(:reservation)
            self.joinout = conf[:joinout]            if conf.has_key?(:joinout)
            self.hard_resreq = conf[:hard_resreq]    if conf.has_key?(:hard_resreq)
            self.soft_resreq = conf[:soft_resreq]    if conf.has_key?(:soft_resreq)
            self.outfile = conf[:outfile]            if conf.has_key?(:outfile)
            self.outfile = conf[:errfile]            if conf.has_key?(:errfile)
            self.cwd = conf[:cwd]                    if conf.has_key?(:cwd)
            self.wd = conf[:wd]                      if conf.has_key?(:wd)
            self.pe = conf[:pe]                      if conf.has_key?(:pe)
            self.pe_slots = conf[:pe_slots]          if conf.has_key?(:pe_slots)
            self.script = conf[:script]              if conf.has_key?(:script)
        end
    end
        
    def submit
        # pull options from the submit hash
        cmdargs  = ""

        # resource requests
        if (self.hard_resreq != nil)
            h_res_req = "-hard -l "
            self.hard_resreq.each_with_index do |res,i|
                if i == self.hard_resreq.length-1
                    h_res_req += "#{res.to_s}"
                else
                    h_res_req += "#{res.to_s},"
                end
            end
        end

        if (self.soft_resreq != nil)
            s_res_req = "-soft -l "
            self.soft_resreq.each_with_index do |res,i|
                if self.soft_resreq.length == i-1
                    s_res_req += "#{res.to_s}"
                else
                    s_res_req += "#{res.to_s},"
                end
            end
        end

        # build our command-line arguments from our accessor info
        cmdargs  = " #{h_res_req}"          if (defined?(h_res_req))
        cmdargs += " #{s_res_req}"          if (defined?(s_res_req))
        cmdargs += " -j y"                  if self.joinout == true
        cmdargs += " -o #{self.outfile}"    if self.outfile != nil
        cmdargs += " -e #{self.errfile}"    if self.errfile != nil
        cmdargs += " -N #{self.job_name}"   if self.job_name != nil
        cmdargs += " -cwd"                  if self.cwd == true
        cmdargs += " -wd #{self.wd}"        if self.wd != nil
        cmdargs += " -q #{self.queue}"      if self.queue != nil
        cmdargs += " -pe #{self.pe} #{self.pe_slots}" if (self.pe != nil and self.pe_slots != nil)

        # TODO: Implement the rest of the switches as hash keys/options

        # we're going to submit a job
        (status,error) = execio "qsub#{cmdargs}", self.script

        # check status
        if status.class == String and status.match(/^Your job [0-9]+.*submitted$/)
            # TODO: :enumerate => :job is still acting funny.  SGE XML is hard to predict
            self.jobid = status.match(/^Your job ([0-9]+).*submitted$/)[1]
            self.state = "qw"
            return 0 
        else
            raise RuntimeError, "Job submission to SGE failed!"
            return nil
        end
    end
    
    # Gotta be able to delete jobs, too
    def delete
        (status,error) = execio "qdel #{self.jobid}", nil
        if status.class == String and status.match(/^.*job.*#{self.jobid}.*/)
            self.state = "d"
            return 0
        else
            raise RuntimeError, "Deletion of job #{self.jobid} failed!"
            return nil
        end
    end

    # provide the hard resource request list for the current RsgeJob
    #def hard_request_list
    #    @jobHr.keys.sort
    #end 

    # Provide the value of the specific hard resource request for the current RsgeJob
    # This returns an RsgeReq
    #def hard_request(cplx)
    #    @jobHr[cplx]
    #end 
   
    # provide the soft resource request list for the current RsgeJob
    #def soft_request_list
    #    @jobSr.keys.sort
    #end 

    # Provide the value of the specific soft resource request for the current RsgeJob
    # This returns an RsgeReq
    #def soft_request(cplx)
    #    @jobSr[cplx]
    #end

end
