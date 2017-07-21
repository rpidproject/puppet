class NagiosPlugin
    OK = 0
    WARNING = 1
    CRITICAL = 2

    def initialize( stream = STDOUT )
        @stream = stream
    end

    def ok( msg )
        @stream.puts( "OK: #{msg}" )
        return OK
    end
    def critical( msg )
        @stream.puts( "CRITICAL: #{msg}" )
        return CRITICAL
    end
    def warning( msg )
        @stream.puts( "WARNING: #{msg}" )
        return WARNING
    end
end
