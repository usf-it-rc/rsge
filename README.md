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
