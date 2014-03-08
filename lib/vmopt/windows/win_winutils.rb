# encoding: utf-8
#功能：提供windows窗口的基本操作
#
require 'win32ole'
WIN32OLE.codepage = WIN32OLE::CP_UTF8
require 'Win32API'
require 'vmopt/ext/string_ext'
require 'rautomation'

=begin rdoc
类名: 通用操作类
描述: 封装系统操作调用相关的内容
=end

module WinUtils

  class KillProcessFailError < RuntimeError; end  #杀死进程失败的错误
  class EmptyFileFailError < RuntimeError; end  #清除目录错误
  class NotFindZipError < RuntimeError; end   #查不到对应的ZIP文件
  class NotFindFileError < RuntimeError; end   #查不到对应文件
  class NotSuitableStringError < RuntimeError; end #未按要求的的字符串
  class NotFindWindowError < RuntimeError; end #查找不到窗口
  class ActivateFailError < RuntimeError; end  #激活窗口失败
  class SSHConnectFailedError < RuntimeError; end #ssh连接失败
  class SSHAuthorFailedError < RuntimeError; end #ssh连接失败
  class SSHUnknownError < RuntimeError; end #ssh连接失败
  class WaitConnectTimeoutError < RuntimeError; end #TCP连接失败异常
  class NoSavePathError < RuntimeError;end #没有路径可保存

=begin rdoc
  参数：无
  作用：检测到除了为简体中文时为中文系统，其余都判断为英文系统.
  返回值：返回国家域名缩写的小写形式
=end      
  def self.os_type
    WIN32OLE.connect('winmgmts:\\\.').ExecQuery("select * from Win32_OperatingSystem").each do |m|
      return "cn" if m.OSLanguage == 4 || m.OSLanguage == 2052
    end
    "en"
  end 

=begin rdoc
  参数:titlename:查找的标题名称,activate_flag = false
  作用：查找是否有给定标题名称的惟一对象,activate_flag表示是否能够激活窗口。
  返回值：找到惟一对象则返回true;找不到或找到为非惟一的则返回false
=end 
  def self.find_single_active_window?(titlename,activate_flag = false)
    find_res=0
    all_rautowindow = RAutomation::Window.windows
    all_rautowindow.each do  |win|
      find_res+=1 if  (win.exists? && win.title !=nil && (win.title.include?(titlename) rescue false)) 
    end
    return false if find_res.to_s != "1" #找到了有多个标题框的内容，直接返回fasle
    rautowindow = RAutomation::Window.new(:title=>titlename,:adapter=>"Autoit")
    if activate_flag
      return false unless rautowindow.exists? #不存在为假;
      rautowindow.WinActivate(rautowindow.title) unless rautowindow.WinActive(rautowindow.title)
      return true if res_status.to_s == "15" 
      return false
    else
      rautowindow.exists?
    end
  end 

=begin rdoc
  参数:要搜索的标题名称和激活窗口标志，激活窗口标志默认为true
  作用：查找是否有查找到给定的标题名称的对话框，如果有则返回RAutomation对
  象，否则返回nil
   返回值：成功找到返回RAutomation的Windows对象
=end 
  def self.find_window(titlename,flag = true)
    rautowindow = RAutomation::Window.new(:title=>titlename,:adapter=>"Autoit")
    raise ::WinUtils::NotFindWindowError,"Not found the windows like #{titlename}." if ! rautowindow.exists?
    if flag 
      res = rautowindow.WinActivate(rautowindow.title) unless rautowindow.WinActive(rautowindow.title)
      raise ::WinUtils::ActivateFailError,"Cant't Activate the Window #{rautowindow.title}" if res.to_s == "0"
    end
    rautowindow
  end 



=begin rdoc
  参数:根据窗口的text来定位title
  作用：查找是否有查找到给定的窗口的text的对话框，如果有则返回RAutomation对
  象，否则的返回false
  返回值：成功找到返回RAutomation的Windows对象
=end 
  def self.find_window_by_text(textname)
    rautowindows = RAutomation::Window.windows
    rautowindows.map do |win|
      return win if win.text.include?(textname)
    end
    nil
  end
  
=begin rdoc 
  参数：process_name：进程名;reserve_process_path:期望路径
  作用：杀掉给定名称的进程，reserve_process_path有值则保留这个环境下的进程
  返回值：若异常则抛出异常，否则返回真  
=end  
  def self.kill_process(process_name,reserve_process_path=nil)
    raise ArgumentError,"the argument can't be nil." if process_name.nil?
    begin
      gbk_reserve_process_path = reserve_process_path.utf8togbk unless reserve_process_path.nil?
      WIN32OLE.connect('winmgmts:\\\.').ExecQuery("SELECT * FROM Win32_Process").each do |item|
        if item.Caption == process_name.utf8togbk
          if gbk_reserve_process_path == nil
            item.Terminate
            next
          end
          next if item.ExecutablePath != nil && item.ExecutablePath.gsub("\\","/").downcase == gbk_reserve_process_path.gsub("\\","/").downcase
          item.Terminate
        end
      end
      return true
    rescue =>err
      raise ::WinUtils::KillProcessFailError,"Kill process: #{process_name.gbktoutf8} failed!err_msg:#{err}"
    end
  end

=begin rdoc 
  参数：process_name：进程名
  作用：查找给定名称的进程，
  返回值：查看是否有找到给定文件名的进程，若有则返回真，若无则返回假 
=end  
  def self.find_process?(process_name)
    raise ArgumentError,"the argument can't be nil." if process_name.nil?
    gbk_process_name = process_name.utf8togbk
    WIN32OLE.connect('winmgmts:\\\.').ExecQuery("SELECT * FROM Win32_Process").each do |item|
      return true if item.Caption.downcase == gbk_process_name.downcase 
    end
    false
 end
  
=begin rdoc
  参数:准备被清空的目录dir或文件
  作用：清空目录下的所有文件;但保留dir目录,若dir为文件就会删除
  返回值：若异常则抛出异常，否则返回真
=end 
  def self.empty_dir(dir)
    raise ArgumentError,"the argument can't be nil." if dir.nil?
    begin
      gbk_dest_dir = dir.utf8togbk      
      Find.find(gbk_dest_dir) do |file|
        next if ! File.exist?(file)
        #next if File.directory?(file) && (file.downcase == gbk_dest_dir.downcase)
        if File.directory?(file)
          FileWinUtils.rm_rf(file)
        else
          File.delete(file)
        end
      end
      return true
    rescue =>err  
      raise ::WinUtils::EmptyFileFailError,"empty_dir #{dir.gbktoutf8} failed!err_msg:#{err}."
    end
  end   

=begin rdoc
  参数:给定的目录，需要查找的文件名
  作用：在给定的目录中查找给定的文件，若查找到时返回这个文件的目路径，否则返回空
  返回值：返回文件所在路径或为空
=end 
  def self.get_filepath(dest_dir,filename)
    raise ArgumentError,"the argument can't be nil." if dest_dir.nil? || filename.nil?  
    gbk_dest_dir = dest_dir.utf8togbk
    gbk_filename = filename.utf8togbk
    Find.find(gbk_dest_dir) do |filepath|
      filepath_arr = filepath.split("/")
      return (Pathname.new(File.expand_path(filepath)).realpath).to_s.gsub("/","\\\\") if (filepath_arr[-1].downcase == gbk_filename.downcase && !File.directory?(filepath) )
    end
    raise ::WinUtils::NotFindFileError,"Not find named :#{filename.gbktoutf8} file in the dir:#{dest_dir.gbktoutf8}."
  end     
=begin rdoc
  参数:两个字符串str1,str2
  作用:去除str1中头部有str2的部分，需要完整匹配
  返回值：被去除后的字符串
=end 
  def self.remove_head_str(str1,str2)
    str1_size = str1.size
    str2_size = str2.size
    raise ::WinUtils::NotSuitableStringError,"the length of str1 need > str2's size." if str1_size<str2_size
    return "" if str1 == str2
    i = 1
    str2_arr_size = str2.split("\n").size
    result_str=""
    str1.each_line do |line|
      if i<=str2_arr_size
        raise ::WinUtils::NotSuitableStringError,"The relation of str1:#{str1.dump} and str2:#{str2.dump} is not suitable." unless str2.include?(line)
        i = i+1
        next
      end
      result_str<<line
    end
    result_str.strip
  end     
  
end #end of WinUtils.
