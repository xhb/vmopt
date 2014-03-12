#encoding: utf-8
#$:.unshift File.join(__FILE__,"..","..")
require "vmopt/utils/wmi"

module Vmopt
class SystemResource

	def get_cpu
		colItems = WMI.execquery ("select * from Win32_Processor")
		for objItem in colItems do
			print "CPU数量:",objItem.NumberOfCores\
			,"  CPU主频",(objItem.MaxClockSpeed/1000.0).round(2)\
			,"GHZ  CPU使用率:",objItem.LoadPercentage,"%\n";
		end
	end

	def get_memory
		colItems = WMI.execquery ("select * from Win32_PhysicalMemory")
		for objItem in colItems do
			memsizestr = objItem.Capacity
			memsizei = memsizestr.to_i/1024/1024  #str转interger		
		end
		availMemorys = WMI.execquery ("select * from Win32_PerfRawData_PerfOS_Memory")
		for availMemory in availMemorys do 
			availstr = availMemory.AvailableMBytes
			availi = availstr.to_i    #str转interger
		end
		print "总物理内存:",memsizei,"M  可用内存",availi,"M 内存使用率"\
		,(((memsizei-availi) * 1.0 /memsizei) * 100).round(1) ,"%\n";
		
	end

end
end #end of module vmopt

