#encoding: utf-8
$:.unshift File.join(__FILE__,"..","..")

require "vmopt/windows/win_net"
module Vmopt
	class NetWork
     
    #功能：显示可用网络接口
    #返回：返回接口名称数组
    def self.show_netinterface()
      WinNet.interfaces
    end
    
    #功能：检查网络接口的连接状态
    #返回：返回状态字串
	def self.show_interface_stat(interface)
      raise WinNetError::NoInterfaceError "Give me no NetWorkinterface" if interface.nil? or interface.empty?       
	  WinNet.netconnstatus[interface]
	end
    
    #功能：给定一个网卡接口名，禁用网卡
    #例子：disable_adapter("本地连接")
    def self.disable_adapter(interface)
      raise WinNetError::NoInterfaceError "Give me no NetWorkinterface" if interface.nil? or interface.empty? 
      adapter =WinNet.network_adapter.select do |inf|
        inf.NetConnectionId == interface ;
      end
      raise WinNetError::NoInterfaceError "Find no interface #{interface}" if adapter.empty?
      
      begin
        pci = adapter[0].PNPDeviceID
        system("devcon.exe /r disable \"@#{pci}\" ");
      rescue Exception => e
        puts e
      end

    end

  end
end

if __FILE__ == $0

  #Vmopt::NetWork.show_netinterface.each { |e| puts e  }

  Vmopt::NetWork.show_netinterface.each do |inf|
    puts  "#{inf} :" + Vmopt::NetWork.show_interface_stat(inf)
  end
  
  Vmopt::NetWork.disable_adapter("本地连接")
  Vmopt::NetWork.disable_adapter("本地连接 2")
  
  Vmopt::NetWork.show_netinterface.each do |inf|
    puts  "#{inf} :" + Vmopt::NetWork.show_interface_stat(inf)
  end

end



