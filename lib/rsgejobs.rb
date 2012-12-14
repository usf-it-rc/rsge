require 'rsgereq'
require 'time'
require 'rexml/document'
require 'rubygems'
require 'nokogiri'
require 'rutilities'
require 'rsgejob'

# Provides methods for viewing GridEngine job information
class RsgeJobs
    # In an 'overloaded' way, create the object based on whether an argument
    # is provided.  This will let us create either a base object with the current
    # job list or provide an object populated with a specific job's data
    def initialize
        if (args[0] != nil)
            conf = args[0]
        else
            conf = Hash.new
        end

	    if (conf.class != Hash)
            raise ArgumentError, "Argument is not a hash! #{conf.class} #{conf}"
        end
        
        if (!defined?(@@jobs) && !defined?(@@jobsHr) && !defined?(@@jobsSr))

            if ($rspec_init == true)
                doc = Nokogiri::XML(open("sample_data/job_list.xml"))
            else
                user = "\\*"
                user = conf[:user] if (conf.has_key?(:user))
                
                state = "a"
                state = conf[:state] if (conf.has_key?(:state))

                doc = Nokogiri::XML(open("|qstat -r -u #{user} -xml -s #{state}"))
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
end
