#encoding: utf-8
require "vmopt/utils/wmi"
require "serialport"

module Vmopt
class SerialPortOperation

=begin
参数：无
功能：查询串口的基本信息
返回值：默认
=end
	def get_serial_port
		data_value=[]
		colItems = WMI.execquery ("select * from Win32_SerialPort")
		for objItem in colItems do
			str = "串口名称:#{objItem.Name},状态:#{objItem.Status}"
			data_value << Hash["#{objItem.DeviceID}",str]
		end
		return data_value
	end
=begin
参数：串口号，写入的字符串
功能：将串口写入字符串
返回值：默认
=end
	def write(strcom,strinput)
		strinput
		begin
		File.open(strcom, 'w+') do |file|
 		file.write(strinput)
 		end
		rescue Exception
			return false
		end
		return true
	end
=begin
参数：串口号
功能：从串口读入字符串
返回值：读到的com口字符串
=end
	def read(strcom)
		begin
		stroutput=""
 		sp = SerialPort.new "#{strcom}", 9600
 	    sp.read_timeout=4000 #定时4秒
 	    stroutput = sp.read(50)
 	    if stroutput.empty?
 	    	return false
 	    end
		rescue Exception
			return false
		end
		return stroutput
	end
end
end #end of module vmopt

