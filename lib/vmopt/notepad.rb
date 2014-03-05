# encoding: utf-8
$:.unshift File.join(__FILE__,"..","..")

require "vmopt/common/utils"

# module Vmopt

# 	class NotePad
	  
# 	  def initialize()
# 	    AutoItX3.run("notepad.exe")
# 	    AutoItX3::Window.wait("无标题 - 记事本")
# 	    @window = AutoItX3::Window.new("无标题 - 记事本")
# 	  end
	  
# 	  def close
#         @window.close
#       end

# 	  def set_text(msg)
# 	    @window.activate
# 	    edit = @window.focused_control
# 	    edit.text = msg
# 	  end
	  
# 	  def read_text
# 	    @window.activate 
# 	    edit = @window.focused_control
# 	    edit.text
# 	  end  

#       def save_to(filepath)
#       	@window.activate
#       	@window.select_menu_item("文件", "另存为")
#       	window_save = AutoItX3::Window.new("另存为")
#       	window_save.activate
#         window_save.focused_control.text = filepath
#         AutoItX3::send_keys("{enter}")

#       end

# 	end
# end

# notepad = Vmopt::NotePad.new()
# notepad.set_text("adfhj")
# puts notepad.read_text
# notepad.save_to("C:\\1.txt")
# notepad.close

module Vmopt

  class NotePad
    
    # 功能：
    # 1.初始化一个notepad程序，如果给定路径，则打开特定路径下的文件，同时激活该窗口
    # 2.如果不给定路径，则打开notepad，同时激活该窗口。
    # 参数：
    # txt_path: 文件路径
    # open_window: 表示需不需要创建该notepad窗口，默认创建,不设置表示获取该窗口
    # 

    def initialize(opt)

      if opt[:txt_path].nil?
        @title = "记事本"
      else  
        basename = File.basename(opt[:txt_path], ".txt").gbktoutf8
        @title = "#{basename} - 记事本"
        @path = opt[:txt_path]
      end

      if opt[:open_window] 
	      opt[:txt_path].nil? ? AutoItX3.run("notepad.exe") : AutoItX3.run("notepad.exe #{opt[:txt_path]}")
	     
      end

      @window = Utils::find_window(/#{@title}/) 

    end
    
    # 功能：
    # 1.对一个激活的窗口设置文本内容
    # 参数：
    # msg：表示即将填充的信息
    def set_text(msg)
    	@window.text_field(:class => "Edit", :id => 15).set(msg)
    end
    
    # 功能：读取一个已经打开的notepad的里面的内容

    def read_text
      @window.text_field(:class => "Edit", :id => 15).value
    end
     
    #功能：点击菜单中的保存按钮来保存文件
    #参数：
    # filepath：
    #   如果指定了filepath 就表示要另外保存在filepath所在文件
    #   如果没有指定filepath 而且 初始化时指定了path，那就只按保存键
    #   如果初始化时没有指定path，要保存时又不提供路径，报异常

    def save(filepath=nil)
      if !filepath.nil?
        @window.WinMenuSelectItem("[CLASS:Notepad]", "", "文件", "另存为")
        savewindow = Utils::find_window(/另存为/)
        savewindow.text_field(:class => "Edit", :id => 1148).set(filepath)
        savewindow.buttons.each do|button| 
          if button.value == "保存(&S)";
           button.click; 
          end
        end
      elsif !@path.nil? and filepath.nil?
        @window.WinMenuSelectItem("[CLASS:Notepad]", "", "文件", "保存")      
      elsif @path.nil? and filepath.nil?
        raise Utils::NoSavePathError,"Not found the save path ."
      end
    end #end of save
    
    #功能：关闭记事本
    def close
      @window.WinClose("[CLASS:Notepad]", "")
    end #end of close

  end #end of class NotePad

end #end of module vmopt


#Vmopt::NotePad.new()
notepad = Vmopt::NotePad.new({:open_window => false,:txt_path => "C:\\t.txt"})
notepad.set_text("hello world")
puts notepad.read_text
notepad.save()
notepad.close
