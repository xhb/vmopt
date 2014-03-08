module Mycmd
  class << self
    def mysystem(cmd)
    	begin
    		stat = system("#{cmd}");
        stat 
    	rescue Exception => e
    		puts e
        return false
    	end
      
    	
    end
  end
end