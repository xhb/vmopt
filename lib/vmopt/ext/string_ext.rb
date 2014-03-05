# encoding: utf-8
#扩展String类，判断字符串是否为并进行字符串转换
require "iconv"

class String
  #判断是否为utf8
  def utf8?  
    unpack('U*') rescue return false  
    true  
  end
  
  #判断是否为utf8
  def gbktoutf8
    return self if self.utf8?
    Iconv.iconv("utf-8","gbk",self).to_s
  end
  
  def utf8togbk
    return self if !self.utf8?
    Iconv.iconv("gbk","utf-8",self).to_s  
  end

end
  