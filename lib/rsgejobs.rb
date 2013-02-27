require 'rsgereq'
require 'time'
require 'rexml/document'
require 'rubygems'
require 'nokogiri'
require 'rsgejob'
require 'rsgestring'

# Provides methods for viewing GridEngine job information
class RsgeJobs
  def initialize(user)
    if $rspec_init == true
      doc = Nokogiri::XML(open("sample_data/job_list.xml"))
    else
      doc = Nokogiri::XML(open("|qstat -r -xml -u #{user} -s a"))
    end

    @@jobs = Hash.new
      
    doc.xpath("*/*/job_list").each do |node|
      state = node.attribute("state").to_s

      jobNumber = node.at_xpath(".//JB_job_number").to_str

      @@jobs[jobNumber] = Hash.new
      @@jobs[jobNumber][:hard_requests] = Hash.new
      @@jobs[jobNumber][:soft_requests] = Hash.new

      @@jobs[jobNumber][:jobid] = jobNumber

      # TODO: Store more attributes
      if (node.at_xpath(".//JB_submission_time").to_s != "")
        @@jobs[jobNumber][:submission_time] = Time.parse(node.at_xpath(".//JB_submission_time").to_s)
      end

      if (node.at_xpath(".//JAT_start_time").to_s != "")
        @@jobs[jobNumber][:start_time] = Time.parse(node.at_xpath(".//JAT_start_time").to_s)
      end

      @@jobs[jobNumber][:job_owner] = node.at_xpath(".//JB_owner").text.to_s
      @@jobs[jobNumber][:job_name] = node.at_xpath(".//JB_name").text.to_s
      @@jobs[jobNumber][:queue_name] = node.at_xpath(".//queue_name").text.to_s
      @@jobs[jobNumber][:state] = node.at_xpath(".//state").text.to_s
      @@jobs[jobNumber][:slots] = node.at_xpath(".//slots").text.to_s
 
      doc.xpath(node.path + "/hard_request").each do |hr|
        @@jobs[jobNumber][:hard_requests].merge!({ hr.attribute("name").to_s.to_sym => hr.text })
      end

      doc.xpath(node.path + "/soft_request").each do |sr|
        @@jobs[jobNumber][:soft_requests].merge!({ sr.attribute("name").to_s.to_sym => sr.text })
      end
    end
  end

  # provide an RsgeJob for each job currently active
  def each
    self.list.each do |jobid|
      yield RsgeJob.new @@jobs[jobid]
    end
  end

  def where_id_is(jobid)
    RsgeJob.new @@jobs[jobid]
  end

  def each_when_name_is(name)
    @@jobs.keys.each { |jobid| yield RsgeJob.new :jobid => jobid if @@jobs[jobid][:job_name] == name }
  end

  def each_when_state_is(state)
    @@jobs.keys.each { |jobid| yield RsgeJob.new :jobid => jobid if @@jobs[jobid][:state] == state }
  end

  def each_when_owner_is(owner)
    @@jobs.keys.each { |jobid| yield RsgeJob.new :jobid => jobid if @@jobs[jobid][:job_owner] == owner }
  end

  def to_hash
    @@jobs
  end

  def count
    @@jobs.keys.count
  end

  # provide an array of the current job ids
  def list
    @@jobs.keys
  end

end
