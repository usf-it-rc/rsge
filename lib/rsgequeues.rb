require 'time'
require 'rexml/document'
require 'nokogiri'
require 'rsgequeue'

class Rsgequeues
    def initialize
        if (!defined?(@@queues) || !defined?(@@hosts))
            doc = Nokogiri::XML(open("|qstat -g c -ext -xml"))
            @@queues = Hash.new
            
            doc.xpath("job_info/cluster_queue_summary").each do |node|
                qName = node.at_xpath(".//name").to_str
                @@queues[qName.to_sym] = Hash.new
                @@queues[qName.to_sym][:name]   = qName
                @@queues[qName.to_sym][:load]    = node.at_xpath(".//load").to_str
                @@queues[qName.to_sym][:used]    = node.at_xpath(".//used").to_str
                @@queues[qName.to_sym][:resv]    = node.at_xpath(".//resv").to_str
                @@queues[qName.to_sym][:avail]   = node.at_xpath(".//available").to_str
                @@queues[qName.to_sym][:total]   = node.at_xpath(".//total").to_str
                @@queues[qName.to_sym][:dis_man] = node.at_xpath(".//disabled_manual").to_str
                @@queues[qName.to_sym][:dis_tmp] = node.at_xpath(".//tmp_disabled").to_s
            end
        end
    end

    # Accessor methods
    def list
        @@queues.keys
    end

    def each
        self.list.each do |queue|
            yield Rsgequeue.new(queue)
        end
    end
end
