require 'rsgehosts'

class Rsgehost < Rsgehosts
    def initialize(host)
        @host = host
        @complexList = Hash.new
        @loadList = Hash.new

        fa = open("|qconf -se " + @host)
        str = fa.read.split("\n")

        str.each_with_index do |line, i|
            line.strip!
            nextline = nil
            line.gsub!(/\s*\\\s*$/) { |match| nextline = str[i+1]; ''}
            if (nextline != nil)
                str.delete_at(i+1)
                line += nextline
                redo
            end
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
    end

    def name
        @host
    end

    def complex_list
        @complexList.keys.sort
    end 

    def complex_value(cplx)
        @complexList[cplx]
    end 

    def load_list
        @complexList.keys.sort
    end 

    def load_value(cplx)
        @complexList[cplx]
    end 
end
