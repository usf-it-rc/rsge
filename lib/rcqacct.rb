# This Class will call qacct and retrieve CPUTIME from SGE,
# based on data taken from a database with UID's present.
class Rcqacct
  # This will be a UID from the cwa_allocations table
  def initialize(uid)
    @uid = uid
    @username = open("|getent passwd #{@uid}").read.chomp.split(":")[0]
  end

  # This translates a userid from a database table to a namsid 
  def uname 
    return @username
  end

  # This will get the actual UID should this class be used oustide
  # of cwa_allocations
  def uid
    @namsid = open("|getent passwd #{@username}").read.chomp.split(":")[2]
  end

  # Let's get the CPU time reported by SGE for all of eternity 
  def cputime
    @rawtime = open("|qacct -o #{@username} |tail -1").read.chomp.scan(/\S+/)[4].to_i
    @rawtime = ((@rawtime /= 60) / 60)
  end

  # Let's get the CPU time reported by SGE for the last 30 days 
  def cputime30
    @rawtime = open("|qacct -o #{@username} -d 30 |tail -1").read.chomp.scan(/\S+/)[4].to_i
    @rawtime = ((@rawtime /= 60) / 60)
  end

  # Add a user to the specified SGE userset list
  def listadd=(list)
    @list = list
    open("|qconf -au #{@username} #{@list} &> /dev/null")
  end

  # Remove a user from specified SGE userset list
  def listdel=(list)
    @list = list
    open("|qconf -du #{@username} #{@list} &> /dev/null")
  end
end
