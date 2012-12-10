require 'rsgereq'
require 'time'
require 'rexml/document'
require 'rubygems'
require 'nokogiri'
require 'hash_accessor'

class RsgeJob < Rsgereq

    extend HashAccessor
    hash_accessor :job, :jobid, :slots, :submission_time, :start_time, :qname,
                  :hqueue, :state, :job_owner

    def initialize(*args)
        if (!defined?(@@jobs) && !defined?(@@jobsHr) && !defined?(@@jobsSr))
            doc = doc = Nokogiri::XML(open("|qstat -r -u \\* -xml"))
            @@jobs = Hash.new
            @@jobsHr = Hash.new
            @@jobsSr = Hash.new
            
            doc.xpath("*/*/job_list").each do |node|
                #state = element.attribute("state").to_s
                state = node.attribute("state").to_s

                @jobNumber = node.at_xpath(".//JB_job_number").to_str

                @@jobs[@jobNumber] = Hash.new
                @@jobsHr[@jobNumber] = Hash.new
                @@jobsSr[@jobNumber] = Hash.new

                @@jobs[@jobNumber][:jobid] = @jobNumber
                @@jobs[@jobNumber][:submission_time] = Time.parse(node.at_xpath(".//JB_submission_time").to_s)
                @@jobs[@jobNumber][:start_time] = Time.parse(node.at_xpath(".//JAT_start_time").to_s)
                @@jobs[@jobNumber][:job_owner] = node.at_xpath(".//JB_owner").text.to_s
                @@jobs[@jobNumber][:qname] = node.at_xpath(".//queue_name").text.to_s
                @@jobs[@jobNumber][:hqueue] = node.at_xpath(".//hard_req_queue").to_s
                @@jobs[@jobNumber][:state] = node.at_xpath(".//state").text.to_s
                @@jobs[@jobNumber][:slots] = node.at_xpath(".//slots").text.to_s
 
                doc.xpath(node.path + "/hard_request").each do |hr|
                    @@jobsHr[@jobNumber][hr.attribute("name").to_s] = Rsgereq.new(hr.attribute("name").to_s, hr.text)
                end

                doc.xpath(node.path + "/soft_request").each do |sr|
                    @@jobsSr[@jobNumber][sr.attribute("name").to_s] = Rsgereq.new(sr.attribute("name").to_s, sr.text)
                end

            end
        else
            @job = @@jobs[args[0]]
            @jobHr = @@jobsHr[args[0]]
            @jobSr = @@jobsSr[args[0]]
        end
    end

    # Accessor methods
    def each
        self.list.each do |jobid|
            yield RsgeJob.new(jobid)
        end
    end

    # One-off accessor methods
    def list
        @@jobs.keys.sort
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
