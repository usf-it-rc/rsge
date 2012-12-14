require 'rsgereq'
require 'time'
require 'rexml/document'
require 'rubygems'
require 'nokogiri'
require 'rsgejob'

# Provides methods for viewing GridEngine job information
class RsgeJobs
    # In an 'overloaded' way, create the object based on whether an argument
    # is provided.  This will let us create either a base object with the current
    # job list or provide an object populated with a specific job's data
    def initialize(*args)
        if (args[0] != nil)
            conf = args[0]
        else
            conf = Hash.new
        end

        if (conf.has_key?(:jobid))
            if !defined?(@@jobs)
                RsgeJobs.new  
            end
            return RsgeJob.new({ :jobid => conf[:jobid] })
        end

        if (!defined?(@@jobs) && !defined?(@@jobsHr) && !defined?(@@jobsSr))
            j_status = "a"
            j_status = conf[:j_status] if conf.has_key?(:j_status)
            j_user = "\\*"
            j_user = conf[:j_user] if conf.has_key?(:j_user)

            if ($rspec_init == true)
                doc = Nokogiri::XML(open("sample_data/job_list.xml"))
            else
                doc = Nokogiri::XML(open("|qstat -r -xml -u #{j_user} -s #{j_status}"))
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
                @@jobs[@jobNumber][:job_name] = node.at_xpath(".//JB_name").text.to_s
                @@jobs[@jobNumber][:queue_name] = node.at_xpath(".//queue_name").text.to_s
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
