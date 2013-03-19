# This class will fix "ugly" list formatting
# code and should negate effects by regex

class SGElist < String
  def initialize(list)
    @list = list
  end

  def listclean
    @list = open("|qconf -su #{@list}").read
    @list.gsub!("\n"," ")
    @list.gsub!(","," ")
    @list.gsub!("\\"," ")
    @list.gsub!(/\s+/,' ')
    return @list
  end
end
