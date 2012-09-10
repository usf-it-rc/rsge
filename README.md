rsge
====

Ruby bindings for GridEngine

Classes

rsgehost
rsgejobs < rsgereq
rsgequeue
rsgereq

## rsgehost ##
~~~
globalHost = Rsgehost.new("global")

puts "Number of matlab licenses max for cluster: " + globalHost.complex_value(:matlab).to_s
~~~

## rsgejobs ##
~~~
jobs = Rsgejobs.new

jobs.list.each do |jobid|
    jobs.set_jobid(jobid)

    puts jobid + jobs.owner + " " + jobs.
~~~

