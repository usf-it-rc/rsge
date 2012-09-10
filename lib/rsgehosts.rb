class Rsgehosts
    def initialize
        @hosts = open("|qconf -sel").read.split("\n")
    end

    def list
        @hosts.sort
    end 

    def each
        @hosts.sort.each do |host|
            yield Rsgehost.new(host)
        end
    end 
end
