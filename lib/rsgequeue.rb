require 'time'
require 'rexml/document'
require 'rubygems'
require 'nokogiri'
require 'rsgeutil'

class RsgeQueue
    extend RsgeUtil
    hash_accessor :queue, :name, :load, :used, :resv, :avail, :total

    # Create a new object which represents all queues or a specified queue
    def initialize(*args)
        if (args[0] != nil)
            if (!defined?(@@queues))
                q_parser
            end
            @queue = @@queues[args[0]]
        elsif (!defined?(@@queues))
            q_parser
        end
    end

    # Accessor methods
    def list
        @@queues.keys
    end

    def each
        self.list.each do |queue|
            yield RsgeQueue.new(queue)
        end
    end

    # Accessor methods
    def disabled
        @queue[:dis_man] + @queue[:dis_tmp]
    end
    
    private

    def q_parser
        if ($rspec_init == true)
            doc = Nokogiri::XML(open("sample_data/queue_status.xml"))
        else
            (output, error) = RsgeUtil.execio "qstat -g c -ext -xml", nil
            doc = Nokogiri::XML(output)
        end

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
