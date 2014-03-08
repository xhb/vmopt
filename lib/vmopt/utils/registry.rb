#encoding: utf-8
#功能：操作注册表，注册硬件信息
module Registry
  class << self
    def hklm_read(key, value)
      require 'win32/registry'
      reg = Win32::Registry::HKEY_LOCAL_MACHINE.open(key)
      rval = reg[value]
      reg.close
      rval
    end
  end
end