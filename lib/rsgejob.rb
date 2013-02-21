require 'rsgereq'
require 'time'
require 'rexml/document'
require 'rubygems'
require 'nokogiri'
require 'rsgejobs'
require 'rsgeutil'

# Provides methods for viewing GridEngine job information
class RsgeJob
  # no-brainer accessors
  attr_accessor :jobid, :job_name, :slots, :submission_time, :start_time, :queue,
                :state, :job_owner, :pe, :pe_slots, :reservation, :cwd, :wd,
                :hard_resreq, :soft_resreq, :joinout, :outfile, :errfile, :script,
                :queue_name, :valid, :hard_requests, :soft_requests

  # In an 'overloaded' way, create the object based on whether an argument
  # is provided.  This will let us create either a base object with the current
  # job list or provide an object populated with a specific job's data
  def initialize(*args)
    extend RsgeUtil

    yield self if block_given?

    if (args[0] != nil)
      conf = args[0]
    else
      conf = Hash.new
    end

    raise ArgumentError, "Argument is not a hash! #{conf.class} #{conf}" if conf.class != Hash

    # We're a valid job unless we run into some condition
    self.valid = true

    if conf.has_key?(:jobid)
      parse_job_by_id conf[:jobid]
    end
  end
    
  def submit
    # pull options from the submit hash
    cmdargs  = ""

    # resource requests
    if self.hard_requests != nil
      reqs = Array.new
      self.hard_requests.keys.each { |cplx| reqs << cplx.to_s + "=" + self.hard_requests[cplx].to_s }
      h_res_req = "-hard -l " + reqs * ","
    end

    if (self.soft_resreq != nil)
      reqs = Array.new
      self.soft_requests.keys.each { |cplx| reqs << cplx.to_s + "=" + self.soft_requests[cplx].to_s }
      s_res_req = "-soft -l " + reqs * ","
    end

    # build our command-line arguments from our accessor info
    cmdargs  = " #{h_res_req}"      if (defined?(h_res_req))
    cmdargs += " #{s_res_req}"      if (defined?(s_res_req))
    cmdargs += " -j y"          if self.joinout == true
    cmdargs += " -o #{self.outfile}"  if self.outfile != nil
    cmdargs += " -e #{self.errfile}"  if self.errfile != nil
    cmdargs += " -N #{self.job_name}"   if self.job_name != nil
    cmdargs += " -cwd"          if self.cwd == true
    cmdargs += " -wd #{self.wd}"    if self.wd != nil
    cmdargs += " -q #{self.queue}"    if self.queue != nil
    cmdargs += " -pe #{self.pe} #{self.pe_slots}" if (self.pe != nil and self.pe_slots != nil)

    # TODO: Implement the rest of the switches as hash keys/options

    # we're going to submit a job
    (status,error) = execio "qsub#{cmdargs}", self.script

    # check status
    if status.class == String and status.match(/^Your job [0-9]+.*submitted$/)
      # TODO: :enumerate => :job is still acting funny.  SGE XML is hard to predict
      parse_job_by_id status.match(/^Your job ([0-9]+).*submitted$/)[1]
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

  private
  def parse_job_by_id(jobid)
    # We're providing a job and its info
    jobs = RsgeJobs.new 

    job   = jobs.to_hash[jobid]

    if job == nil
      self.valid = false
      return self
    end

    self.jobid        = jobid
    self.job_owner    = job[:job_owner]
    self.job_name     = job[:job_name]
    self.queue        = job[:queue]
    self.queue_name   = job[:queue_name]
    self.reservation  = job[:reservation] 
    self.joinout      = job[:joinout]
    self.state        = job[:state]
    self.slots        = job[:slots]
    self.hard_requests  = job[:hard_requests]
    self.soft_requests  = job[:soft_requests]

    #self.pe = conf[:pe]            if conf.has_key?(:pe)
    #self.pe_slots = conf[:pe_slots]      if conf.has_key?(:pe_slots)
    #self.script = conf[:script]        if conf.has_key?(:script)
  end

  # provide the hard resource request list for the current RsgeJob
  #def hard_request_list
  #  @jobHr.keys.sort
  #end 

  # Provide the value of the specific hard resource request for the current RsgeJob
  # This returns an RsgeReq
  #def hard_request(cplx)
  #  @jobHr[cplx]
  #end 
   
  # provide the soft resource request list for the current RsgeJob
  #def soft_request_list
  #  @jobSr.keys.sort
  #end 

  # Provide the value of the specific soft resource request for the current RsgeJob
  # This returns an RsgeReq
  #def soft_request(cplx)
  #  @jobSr[cplx]
  #end

end
