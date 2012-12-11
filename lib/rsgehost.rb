# RsgeHost has methods for obtaining information about hosts in a GridEngine
# environment.  Eventually, we will also include methods for setting host 
# complex values, enabling/disabling, add/remove, hostgroup associations, etc.
class RsgeHost
    # instantiate new object in a "overloaded" way
    # * Without arguments, we can provide a hostlist
    # * With an argument (e.g. a host), we can provide the details of the host
    def initialize(*args)
        if (args[0] != nil)
            @host = args[0]
            @complexList = Hash.new
            @loadList = Hash.new

            if (!defined?(@hosts))
                if ($rspec_init == true)
                    @hosts = open("sample_data/host_list.txt").read.split("\n")
                else
                    @hosts = open("|qconf -sel").read.split("\n")
                end
            end

            if ($rspec_init == true)
                fa = open("sample_data/compute_host.txt")
            else
                fa = open("|qconf -se " + @host)
            end

            str = fa.read.split("\n")
            fa.close
            
            # Given a host, lets parse the output of `qconf -se *hostname*`... we'll need to deal 
            # with pesky multi-lines and line continuation characters
            nextline = nil
            str.each_with_index do |line, i|
                line.chomp!

                line = nextline + line if nextline != nil

                if (/[ ]+\\[ ]*$/.match(line))
                    nextline = line.gsub(/[ ]+\\[ ]*$/,"") if nextline == nil
                    nextline += str[i+1].strip.gsub(/[ ]+\\[ ]*$/,"")
                    next
                end

                nextline = nil

                if line.match(/^complex_values[ ]+.*/)
                    line.gsub!(/complex_values[ ]+/, "")
                    line.gsub!(/,\s*/, ",")
                    cplx = line.split(",")

                    cplx.each do |pair|
                        @complexList[(pair.split("="))[0].to_sym] = (pair.split("="))[1] 
                    end
                end
                if line.match(/^load_values[ ]+.*/)
                    line.gsub!(/load_values[ ]+/, "")
                    line.gsub!(/,\s*/, ",")
                    cplx = line.split(",")

                    cplx.each do |pair|
                        @loadList[(pair.split("="))[0].to_sym] = (pair.split("="))[1] 
                    end
                end
            end
        else
            if ($rspec_init == true)
                @hosts = open("sample_data/host_list.txt").read.split("\n")
            else
                @hosts = open("|qconf -sel").read.split("\n")
            end
        end 
    end

    # get an array of hosts configured in the GridEngine environment
    def list
        @hosts.sort
    end 

    # for each host, return a new RsgeHost
    def each
        @hosts.sort.each do |host|
            yield RsgeHost.new(host)
        end 
    end

    # hostname of the current RsgeHost
    def name
        @host
    end

    # list defined complex attributes
    def complex_list
        @complexList.keys.sort
    end 

    # get value for specified complex attribute
    def complex_value(cplx)
        @complexList[cplx]
    end 

    # list load attributes
    def load_list
        @loadList.keys
    end 

    # get value for specified load attribute
    def load_value(cplx)
        @loadList[cplx]
    end 
end
