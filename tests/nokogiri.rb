#!/usr/bin/ruby
#
#

require 'rubygems'
require 'nokogiri'
#require 'hash'
#require 'active_support'

doc = Nokogiri::XML(open("|qstat -r -u \\* -xml"))
doc.xpath("*/*/job_list").each do |node|

    jobId = node.at_xpath(".//JB_job_number").to_str

    doc.xpath(node.path + "/hard_request").each do |hr|
        name  = hr.attribute("name").to_s
        value = hr.text
        puts jobId + " " + name + "=" + value
    end
end


#jobs = Hash.from_xml(xmlQstat)

#p jobs

#jobs[:job_info][:queue_info][:job_list].each do |job|
#    if (job[:JB_job_number].to_s == "41399")
#        printf("%s %s %s", job[:JB_job_number], job[:JB_owner],job[:slots])
        #job[:hard_request].keys.each do |cplx|
        #    print cplx + "=" + job[:hard_request][cplx]
        #end
#        p job
#    end
#end
