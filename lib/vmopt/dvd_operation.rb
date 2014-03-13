#encoding: utf-8
require "vmopt/utils/wmi"
require "au3"
require "Win32API"
module Vmopt
class DVDOperation
=begin
参数：无
功能：获取光驱的基本信息
返回值：默认
=end
	def get_dvd_information()
		data_value=[]
		colItems = WMI.execquery ("select * from Win32_CDROMDrive")
		for colItem in colItems do	
			str = "介质类型:#{colItem.MediaType} 盘符:#{colItem.Drive} 描述信息:#{colItem.Description}"
			data_value << Hash["#{colItem.Drive}",str]		
		end
		return data_value
	end

=begin
参数：无
功能：弹出光驱
返回值：默认	
=end
	def eject_dvd(str1="set cdauto door open",str2="",num1=0,num2=0)
		mci = Win32API.new("winmm.dll","mciSendString",%w(p p i i),"i")
		mci.call(str1,str2,num1,num2)
	end

=begin
参数：无
功能：关闭光驱与弹出光驱对应
返回值：默认
=end
	def close_dvd(str1="set cdauto door closed",str2="",num1=0,num2=0)
		mci = Win32API.new("winmm.dll","mciSendString",%w(p p i i),"i")
		mci.call(str1,str2,num1,num2)		
	end

=begin 
参数：无
功能：禁用系统所有的光驱设备
返回值：默认
=end
	def disable_all_dvd
		system("devcon.exe disable *DVD*")
	end

=begin
参数：盘符号例如D:
功能：禁用指定盘符的光驱设备
返回值：默认
=end
	def disable_index_dvd(str)
		colItems = WMI.execquery ("select * from Win32_CDROMDrive where Drive='#{str}'")	
		for colItem in colItems do	
			strID = colItem.DeviceId
			system("devcon.exe disable @#{strID}")
		end			
	end

=begin 
参数：无
功能：启用系统所有的光驱设备
返回值：默认
=end
	def enable_all_dvd
		system("devcon.exe enable *DVD*")
	end


=begin 
参数：无
功能：删除或卸载统所有的光驱设备
返回值：默认
=end
	def remove_all_dvd
		system("devcon.exe remove *DVD*")
	end

=begin
参数：盘符号例如D:
功能：删除或卸载指定盘符的光驱设备
返回值：默认
=end
	def remove_index_dvd(str)
		colItems = WMI.execquery ("select * from Win32_CDROMDrive where Drive='#{str}'")	
			for colItem in colItems do	
				strID = colItem.DeviceId
				system("devcon.exe remove @#{strID}")
			end			
	end
=begin
参数：无
功能：自动添加或者挂载所有光驱设备
返回值：默认
=end
	def mount_all_dvd
		system("devcon.exe rescan")
	end

=begin
参数：盘符号例如D:
功能：打开光盘里的内容
返回值：默认
=end
	def read_dvd(str)
		#AutoItX3.run("explorer.exe #{str}")
		system("dir  #{str}")
	end
end

end #module vmopt


