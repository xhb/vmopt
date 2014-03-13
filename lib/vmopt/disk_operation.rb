#encoding: utf-8
require "vmopt/utils/wmi"
require "json"
module Vmopt
class DiskOperation

=begin
参数：无
作用：查找物理磁盘的基本信息，并打印出来
返回值：默认
=end
	def get_disk_information
		data_value=[]
		colItems = WMI.execquery ("select * from Win32_DiskDrive")
        for colItem in colItems do
        	size=colItem.size
			size=(size.to_i/1048576).to_s
        	str="磁盘ID:#{colItem.DeviceID}  磁盘索引:#{colItem.Index} 接口类型: #{colItem.InterfaceType} 磁盘容量:#{size}M"
        	data_value << Hash["disk#{colItem.Index}",str]
        end
        return data_value
	end
=begin
参数：无
作用：查找磁盘分区的基本信息，并打印出来
返回值：默认
=end
	def get_partition_information
		data_value=[]
		colItems = WMI.execquery ("select * from Win32_LogicalDisk where DriveType=3")
        for colItem in colItems do
			size=colItem.size
			size=(size.to_i/1048576).to_s
			freeSpace=colItem.FreeSpace
			freeSpace=(freeSpace.to_i/1048576).to_s

        	str="逻辑驱动器号:#{colItem.DeviceID} 文件系统:#{colItem.FileSystem} 分区容量#{size}M  剩余容量 #{freeSpace}M"
        	data_value << Hash["partition#{colItem.DeviceID}",str]
        end
   		return data_value
	end
		
=begin
参数：无
功能：判断哪些磁盘没有格式化
返回值：没有格式化的磁盘索引号
=end
	def unformat_disk
		data_value = []
		colItems = WMI.execquery ("select * from Win32_DiskDrive")
        for colItem in colItems do
        	if colItem.Partitions==0
        		str="#{colItem.Index}"
        		data_value << Hash["index#{colItem.Index}",str]
        	end      	
        end
        return  data_value
	end
=begin rdoc
参数：无
功能：格式化磁盘,供其他方法调用
返回值：默认
=end
	def format_disk()
		ret1= system("diskpart /s c:/1.txt")
		ret2 = system("format /FS:NTFS /force /Q F: " )
		return ret1 && ret2
	end
=begin	
参数：无
功能：扫描整个系统磁盘，若存在没有格式化的磁盘则进行格式化
返回值：默认	
=end
	def chk_format_disk
		colItemindexs = WMI.execquery ("select * from Win32_DiskDrive")
		index = []
        for colItemindex in colItemindexs do
        	if colItemindex.Partitions==0
        		index.push(colItemindex.Index)
        	end      	
        end
        if index.empty?
        	return false
        end
		for i in index do
			colItems = WMI.execquery ("select * from Win32_DiskDrive where index=#{i}")
			for colItem in colItems do
				size=colItem.size
				size=(size.to_i/1048576).to_s
			end
			
			logicalcolItems = WMI.execquery ("select * from Win32_LogicalDisk")
			str=[]
	        for colItem in logicalcolItems do
	        	str.push(colItem.DeviceID)
	        	volumename=str.sort!.last.next
	        end

			File.open("c:/1.txt","w")do|file|
			file.puts "select disk=#{i}"
			file.puts "create partition primary size=#{size}"
			file.puts "assign letter=#{volumename}"
		    end
			unless format_disk()
			 	return false
			end 
		File.delete("c:/1.txt")
		end
		return true
	end
=begin	
参数：磁盘索引号
功能：根据指定的磁盘索引号
返回值：指定的磁盘已经被格式化返回false,成功格式化返回true
=end
	def format_disk_by_index(index)

		indexEffectives = WMI.execquery("select * from Win32_DiskDrive ")
			 indexarr=[]
			 for indexeff in indexEffectives do
			 	indexarr.push(indexeff.index)
			 end
		if index<0 or index > indexarr.sort!.last 
		   return false 
		end

		
		colItems = WMI.execquery ("select * from Win32_DiskDrive where index=#{index}")
		for colItem in colItems do
        	if colItem.Partitions==0
        		size=colItem.size
				size=(size.to_i/1048576).to_s
        	else
        		return false
        	end
        end
        logicalcolItems = WMI.execquery ("select * from Win32_LogicalDisk")
		    str=[]
        for colItem in logicalcolItems do
        	str.push(colItem.DeviceID)
        	volumename=str.sort!.last.next
        end

		File.open("c:/1.txt","w") do|file|
		file.puts "select disk=#{index}"
		file.puts "create partition primary size=#{size}"
		file.puts "assign letter=#{volumename}"
		end
		return false unless format_disk()
		#File.open("c:/1.txt","w+")
		File.delete("c:/1.txt")
		return true
	end 
end
end #module vmopt
