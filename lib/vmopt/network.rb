#encoding: utf-8
#$:.unshift File.join(__FILE__,"..","..")
require "vmopt/windows/win_net"
require "vmopt/ext/string_ext"

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
      adapter(interface);      
	    WinNet.netconnstatus[interface]
	  end
    
    #功能：检查接口是否存在，返回接口名对应的适配器
    def self.adapter(interface)
      raise WinNetError::NoInterfaceError "Give me no NetWorkinterface" if interface.nil? or interface.empty? 
      adapter =WinNet.network_adapter.select do |inf|
        inf.NetConnectionId == interface ;
      end
      raise WinNetError::NoInterfaceError "Find no interface #{interface}" if adapter.empty?
      adapter[0]
    end
    
    #功能：执行devcon命令 
    def self.devcon_exec(cmd)
        status = system("#{cmd}");
        status
    end

    #功能：给定一个网卡接口名，卸载网卡
    #例子：adapter_opt("本地连接 2"，"禁用")
    def self.adapter_opt(interface, opt)
      pci = adapter(interface).PNPDeviceID;
      optt=case opt
           when "卸载" then "remove"
           when "禁用" then "disable"
           when "启用" then "enable"
           else raise WinNetError::InvalidParamError "Unkown option for adapter.-#{opt}"
           end
      
      cmd = "devcon.exe /r #{optt} \"@#{pci}\" "
      devcon_exec(cmd)
    end
    
    # #功能：安装一个网卡,暂时不做了，用户需要获取网卡的描述
    # def self.adapter_install()
    #    devcon /r install C:\windows\system32\drivers\rtl8139.sys 硬件ID
    # end

    #功能：扫描硬件改动
    #
    def self.adapter_rescan()
      cmd = "devcon.exe rescan"
      devcon_exec(cmd)
    end
    
    #功能：返回网卡描述信息，用来判断网卡型号
    def self.adapter_discript()
      description=[]
      WinNet.network_adapter_configurations.each do |interface| 
        description << interface.description 
      end
      description
    end
   
    #功能：设置网卡的配置模式为dhcp
    def self.adapter_set_dhcp(interface)
      adapter(interface);
      interface = "\""+interface.to_gbk+"\""
      ipset_cmd = "netsh interface ip set address name=#{interface} source=dhcp".to_gbk
      dnsset_cmd = "netsh interface ip set dns name=#{interface} source=dhcp".to_gbk
      ipset_status = system("#{ipset_cmd}");
      dnsset_status = system("#{dnsset_cmd}");
      
      ipset_status & dnsset_status

    end
    
    #功能：设置网卡为配置的参数
    def self.adapter_set_static(interface, opt={})
      adapter(interface);
      interface = "\""+interface.to_gbk+"\""
      ipset_cmd = "netsh interface ip set address name=#{interface} source=static addr=#{opt[:addr]} mask=#{opt[:mask]}".to_gbk
      gwset_cmd = "netsh interface ip set address name=#{interface} gateway=#{opt[:gateway]} gwmetric=0".to_gbk
      dnsset_cmd = "netsh interface ip set dns name=#{interface} source=static addr=202.106.128.86 register=primary".to_gbk
      dns2set_cmd = "netsh interface ip add dns name=#{interface} addr=8.8.8.8 index=2".to_gbk
      
      ipset_status = system(ipset_cmd) 
      gwset_status = system(gwset_cmd)
      dns_status = system(dnsset_cmd)
      dns2_staus = system(dns2set_cmd)

      ipset_status & dns_status & dns2_staus & gwset_status

    end

  end
end

if __FILE__ == $0
 
  Vmopt::NetWork.show_netinterface.each { |e| puts (e) }
  Vmopt::NetWork.show_netinterface.each do |inf|
    puts  "#{inf} :" + Vmopt::NetWork.show_interface_stat(inf)
  end
  Vmopt::NetWork.adapter_opt("本地连接 4", "禁用")   
  Vmopt::NetWork.adapter_opt("本地连接 4", "启用")
  #Vmopt::NetWork.adapter_opt("本地连接 3", "卸载")
  # Vmopt::NetWork.adapter_rescan
  # sleep 10
  Vmopt::NetWork.adapter_discript.each{|d| puts (d) }
   
  Vmopt::NetWork.adapter_set_static("本地连接 4", {:addr => "192.168.12.10", :mask => "255.255.252.0", :gateway => "192.168.12.1"})
  Vmopt::NetWork.adapter_set_dhcp("本地连接 4")
  
end



