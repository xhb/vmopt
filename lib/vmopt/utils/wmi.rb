#encoding: utf-8
#功能：wmi模块，用于查询本地设备信息
module WMI
  class << self
    def connect(uri = wmi_resource_uri)
      require 'win32ole'
      WIN32OLE.codepage = WIN32OLE::CP_UTF8
      WIN32OLE.connect(uri)
    end

    def wmi_resource_uri( host = '.' )
      "winmgmts:{impersonationLevel=impersonate}!//#{host}/root/cimv2"
    end

    def execquery(query)
      connect().execquery(query)
    end
  end
end
