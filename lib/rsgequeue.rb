require 'time'
require 'rexml/document'
require 'nokogiri'

class Rsgequeue < Rsgequeues

    def initialize(queue)
        @queue = @@queues[queue]
    end

    # Accessor methods
    def name
        @queue[:name]
    end

    def load
        @queue[:load]
    end

    def used
        @queue[:used]
    end

    def reserved
        @queue[:resv]
    end

    def available
        @queue[:avail]
    end

    def total
        @queue[:total]
    end

    def disabled
        @queue[:dis_man] + @queue[:dis_tmp]
    end
end
