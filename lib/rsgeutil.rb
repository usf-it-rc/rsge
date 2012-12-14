# Code shamelessly lifted from Sean O'halpin
# http://www.ruby-forum.com/topic/2189875
#
require "open3"

module RsgeUtil
    # Say we have an object variable that's a hash.  We might want
    # accessors for a bunch of its keys, right?
    def hash_accessor(hash_name, *key_names)
        key_names.each do |key_name|
            define_method key_name do
                instance_variable_get("@#{hash_name}")[key_name]
            end
            define_method "#{key_name}=" do |value|
                instance_variable_get("@#{hash_name}")[key_name] = value
            end
        end
    end
    def execio(cmd, stdin)
        output = ""
        error  = ""
        Open3.popen3(cmd){ |i,o,e,t|
            i.puts stdin
            i.close
            output = o.gets
            o.close
            error  = e.gets
            e.close
        }
        return [output,error]
    end
end
