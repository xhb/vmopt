#encoding: utf-8

class SerialPortOperation

=begin
参数：无
功能：查询串口的基本信息
返回值：默认
=end
	def get_serial_port
		colItems = WMI.execquery ("select * from Win32_SerialPort")
		for objItem in colItems do
			print "串口名称:",(objItem.Name),"状态:",objItem.Status,"\n"
		end
	end
=begin
参数：串口号，写入的字符串
功能：将串口写入字符串
返回值：默认
=end
	def write(strcom,strinput)
		strinput.to_gbk
		begin
		File.open(strcom, 'w+') do |file|
 		file.write(strinput)
 		end
		rescue Exception
			print "Can't open #{strcom},Please input right serialport name"
		end
	end
=begin
参数：串口号
功能：从串口读入字符串
返回值：读到的com口字符串
=end
	def read(strcom)
		begin
		stroutput=""
		File.open(strcom, 'w+') do |file|
 		stroutput=file.read(50)
 		end
		rescue Exception
			print "Can't open #{strcom},Please input right serialport name"
		end
		return stroutput.to_gbk
	end
end

