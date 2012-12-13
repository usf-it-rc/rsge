require 'rsgereq'
require 'time'
require 'rexml/document'
require 'rubygems'
require 'nokogiri'
require 'hash_accessor'
require 'open3'

# Provides methods for viewing GridEngine job information
class RsgeJob
    extend HashAccessor

    # no-brainer accessors
    hash_accessor :job, :jobid, :slots, :submission_time, :start_time, :qname,
                  :hqueue, :state, :job_owner

    # In an 'overloaded' way, create the object based on whether an argument
    # is provided.  This will let us create either a base object with the current
    # job list or provide an object populated with a specific job's data
    def initialize(*args)
        if (args[0] != nil)
            conf = args[0]
        else
            conf = Hash.new
        end

	    if (conf.class != Hash)
            raise ArgumentError, "Argument is not a hash! #{conf.class} #{conf}"
        end
        
        # set default options for our hash
        conf[:enumerate] == :all if !defined?(conf[:enumerate])

        if (defined?(conf[:submit]) and conf[:submit] == true)
            # pull options from the submit hash
            cmdargs  = ""
            cmdargs  = " -hard -l #{conf[:hard_resreq]}"  if conf.has_key?(:hard_resreq)
            cmdargs += " -soft -l #{conf[:soft_resreq]}"  if conf.has_key?(:soft_resreq)
            cmdargs += " -j y" if (conf.has_key?(:joinout) and conf[:joinout] == true)
            cmdargs += " -o #{conf[:outfile]}" if conf.has_key?(:outfile)
            cmdargs += " -e #{conf[:errfile]}" if conf.has_key?(:errfile)
            cmdargs += " -N #{conf[:job_name]}" if conf.has_key?(:job_name)
            cmdargs += " -cwd" if (conf.has_key?(:cwd) and conf[:cwd] == true)
            cmdargs += " -wd #{conf[:wd]}" if conf.has_key?(:wd)
            cmdargs += " -q #{conf[:queue]}" if conf.has_key?(:queue)
            cmdargs += " -pe #{conf[:pe]} #{conf[:pe_slots]}" if (conf.has_key?(:pe) and conf.has_key?(:pe_slots))

            # TODO: Implement the rest of the switches as hash keys/options

            # we're going to submit a job
            status = ""

            Open3.popen3("qsub#{cmdargs}"){ |i,o,e,t|
                i.puts conf[:script]
                i.close
                status = o.gets
                o.close
                e.close
            }

            # check status
            if status.class == String and status.match(/^Your job [0-9]+.*submitted$/)
                # TODO: :enumerate => :job is still acting funny.  SGE XML is hard to predict
                jobid = status.match(/^Your job ([0-9]+).*submitted$/)[1]
                return RsgeJob.new( { :enumerate => :job, :jobid => jobid } )
            else
                raise RuntimeError, "Job submission to SGE failed!"
                return nil
            end

            # Return an RsgeJob that we can work with :)

        elsif (!defined?(@@jobs) && !defined?(@@jobsHr) && !defined?(@@jobsSr))

            if ($rspec_init == true)
                doc = Nokogiri::XML(open("sample_data/job_list.xml"))
            else
                user = "\\*"
                user = conf[:user] if (conf.has_key?(:user))
                
                state = "a"
                state = conf[:state] if (conf.has_key?(:state))

                if (conf[:enumerate] == :all)
                    doc = Nokogiri::XML(open("|qstat -r -u #{user} -xml -s #{state}"))
                else
                    doc = Nokogiri::XML(open("|qstat -r -u #{user} -xml -j #{conf[:jobid]} -s #{state}"))
                end
            end

            @@jobs = Hash.new
            @@jobsHr = Hash.new
            @@jobsSr = Hash.new
            
            doc.xpath("*/*/job_list").each do |node|
                state = node.attribute("state").to_s

                @jobNumber = node.at_xpath(".//JB_job_number").to_str

                @@jobs[@jobNumber] = Hash.new
                @@jobsHr[@jobNumber] = Hash.new
                @@jobsSr[@jobNumber] = Hash.new

                @@jobs[@jobNumber][:jobid] = @jobNumber

                # TODO: Store more attributes
                if (node.at_xpath(".//JB_submission_time").to_s != "")
                    @@jobs[@jobNumber][:submission_time] = Time.parse(node.at_xpath(".//JB_submission_time").to_s)
                end

                if (node.at_xpath(".//JAT_start_time").to_s != "")
                    @@jobs[@jobNumber][:start_time] = Time.parse(node.at_xpath(".//JAT_start_time").to_s)
                end

                @@jobs[@jobNumber][:job_owner] = node.at_xpath(".//JB_owner").text.to_s
                @@jobs[@jobNumber][:qname] = node.at_xpath(".//queue_name").text.to_s
                @@jobs[@jobNumber][:hqueue] = node.at_xpath(".//hard_req_queue").to_s
                @@jobs[@jobNumber][:state] = node.at_xpath(".//state").text.to_s
                @@jobs[@jobNumber][:slots] = node.at_xpath(".//slots").text.to_s
 
                doc.xpath(node.path + "/hard_request").each do |hr|
                    @@jobsHr[@jobNumber][hr.attribute("name").to_s] = RsgeReq.new(hr.attribute("name").to_s, hr.text)
                end

                doc.xpath(node.path + "/soft_request").each do |sr|
                    @@jobsSr[@jobNumber][sr.attribute("name").to_s] = RsgeReq.new(sr.attribute("name").to_s, sr.text)
                end

            end
        else
            jobid = conf[:jobid]
            @job = @@jobs[jobid]
            @jobHr = @@jobsHr[jobid]
            @jobSr = @@jobsSr[jobid]
        end
    end

    # provide an RsgeJob for each job currently active
    def each
        self.list.each do |jobid|
            yield RsgeJob.new( { :jobid => jobid } )
        end
    end

    # provide an array of the current job ids
    def list
        @@jobs.keys.sort
    end

    # provide the hard resource request list for the current RsgeJob
    def hard_request_list
        @jobHr.keys.sort
    end 

    # Provide the value of the specific hard resource request for the current RsgeJob
    # This returns an RsgeReq
    def hard_request(cplx)
        @jobHr[cplx]
    end 
   
    # provide the soft resource request list for the current RsgeJob
    def soft_request_list
        @jobSr.keys.sort
    end 

    # Provide the value of the specific soft resource request for the current RsgeJob
    # This returns an RsgeReq
    def soft_request(cplx)
        @jobSr[cplx]
    end

end
