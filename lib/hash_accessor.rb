# Code shamelessly lifted from Sean O'halpin
# http://www.ruby-forum.com/topic/2189875
#
module HashAccessor
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
end
