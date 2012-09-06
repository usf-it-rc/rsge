class Rsgereq
    def initialize(type, value)
        @value = value
        @type = type
        case type
         when "MEMORY"
            @value = _mem_convert
         when "STRING"

         when "INT"

         when "DOUBLE"

         when "TIME"

         when "HOST"

         when "BOOL"

         else
            puts "Not a valid type " + type.to_s + " for complex"
        end
    end

    def as_gibi
        return (@value.to_f/(1024**3)).to_s
    end

    def as_giga
        return (@value.to_f/(1000**3)).to_s
    end

    def as_mibi
        return (@value.to_f/(1024**2)).to_s
    end

    def as_mega
        return (@value.to_f/(1000**2)).to_s
    end

    def as_kibi
        return (@value.to_f/1024).to_s
    end

    def as_kilo
        return (@value.to_f/1000).to_s
    end

    def value
        return (@value.to_s)
    end

    def _mem_convert

        case @value
            when /[0-9\.]+G/
                return @value.gsub("G","").to_i * (1024**3)
            when /[0-9\.]+g/
                return @value.gsub("g","").to_i * (1000**3)
            when /[0-9\.]+M/
                return @value.gsub("M","").to_i * (1024**2)
            when /[0-9\.]+m/
                return @value.gsub("m","").to_i * (1000**2)
            when /[0-9\.]+K/
                return @value.gsub("K","").to_i * (1024)
            when /[0-9\.]+k/
                return @value.gsub("k","").to_i * (1000)
            else
                return @value
        end
    end

    def _private_time
    end
    
    def _private_time_date
    end

    private :_mem_convert
end
