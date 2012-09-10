rsge
====

Ruby bindings for GridEngine

Classes

+ rsgehost
+ rsgejobs < rsgereq
+ rsgequeue
+ rsgereq

## rsgehost ##
~~~
globalHost = Rsgehost.new("global")

puts "Number of matlab licenses max for cluster: " + globalHost.complex_value(:matlab).to_s
~~~
### Methods ###
+ (array) complex_list
+ (string) complex_value
+ (array) load_list
+ (string) load_value

## rsgejobs ##
~~~
jobs = Rsgejobs.new

jobs.each do |job|
    puts job.jobid + " " + job.owner + " " + job.state
end
...
1 user1 r
2 user2 r
3 user1 r
4 user3 w
~~~
### Methods (rsgejobs) ###
+ each
+ list

### Methods (rsgejob) (all return string) ###
+ jobid
+ slots
+ subTime
+ startTime
+ queueName
+ hardReqQueue
+ state
+ owner
+ hardRequestList
+ hardRequest
+ softRequestList
+ softRequest

## rsgequeue ##
~~~
require 'rsgequeue'

queues = Rsgequeues.new

queues.each do |queue|
    puts queue.name.to_s + " " + queue.used.to_s + " " + queue.available.to_s + " " + queue.total.to_s
end
~~~
### Methods (rsgequeue) ###
+ list
+ each

### Methods (rsgequeue) (all return string) ###
+ name
+ load
+ used
+ reserved
+ available
+ total
+ disabled

## rsgehost ##
Still under development... not expected to work.
