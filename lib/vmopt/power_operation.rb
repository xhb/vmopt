#encoding: utf-8
module Vmopt
class PowerOperation

=begin
参数：无
功能：关机
返回值：默认
=end
	def shutdown
		system("shutdown -s -t 00")
	end

=begin
参数：无
功能：重启
返回值：默认
=end
	def reboot
		system("shutdown -r -t 00")
	end


=begin
参数：无
功能：注销
返回值：默认
=end
	def logoff
		system("shutdown -l")
	end


=begin
参数：无
功能：锁定或切换用户
返回值：默认
=end
	def lock_user
		system("rundll32.exe user32.dll LockWorkStation")
	end

=begin
参数：无
功能：休眠，xp没有休眠的功能，win7有休眠的功能
返回值：默认
=end
	def sleep
		system("rundll32.exe powrprof.dll SetSuspendState")
	end

end
end #end of module vmopt

if __FILE__ == $0
	PowerOperation.new().lock_user
end