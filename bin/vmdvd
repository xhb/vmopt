#!/usr/bin/env ruby
#encoding: utf-8

require "vmopt/dvd_operation"
require "optparse"

option = {}
option_parser = OptionParser.new do | opts |
  opts.banner = %q/
  Help: 
    Description:
      vmdrive tool, use for DVD\CD drive operation.
    function:
      1.get_dvd_information        
      2.eject_dvd
      3.close_dvd
      4.disable_all_dvd
      5.disable_index_dvd
      6.enable_all_dvd
      7.remove_all_dvd
      8.remove_index_dvd
      9.mount_all_dvd
      10.read_dvd

    Example:
      vmdvd --query  dvd_information    
      vmdvd --query  read_dvd --path disksymbol

      vmdvd --disable  disable_all_dvd
      vmdvd --disable  disable_index_dvd --index diskindex
      vmdvd --enable   enable_all_dvd

      vmdvd --remove  remove_all_dvd
      vmdvd --mount   mount_all_dvd
      vmdvd --remove  remove_index_dvd  --index diskindex

      vmdvd --eject   eject_dvd
      vmdvd --close   close_dvd
  /
  #查询时使用
  opts.on('-q queryopt', '--query queryopt', 'Query DVD/CD information') do |value|
    option[:cmd] = "query"
    option[:queryopt] = value
  end
  opts.on('-s disksymbol', '--symbol disksymbol', 'list DVD/CD files') do |value|
    option[:disksymbol] = value
  end
  
  #禁用时使用
  opts.on('-d disableopt', '--disable disableopt', 'Specify dvd option to disable') do |value|
    option[:disable_opt] = value
    option[:cmd] = "disable"
  end
  
  #启用时使用
  opts.on('-e alldisk', '--enable alldisk', 'Enable all dvd drive') do |value|
    option[:enabl_all_disks] = value
    option[:cmd] = "enable"
  end

  #卸载光驱时使用
  opts.on('-r remov_disks', '--remove remov_disks', 'remove dvd drive') do |value|
    option[:remov_disks] = value
    option[:cmd] = "remove"
  end
  
  #挂载全部磁盘
  opts.on('-m mount_all_dvd', '--mount mount_all_dvd', 'mount all dvd drive') do |value|
    option[:mount_all_dvd] = value
    option[:cmd] = "mount"
  end
  
  #弹出光驱
  opts.on('-j enject_dvd', '--enject enject_dvd', 'mount all dvd drive') do |value|
    option[:enject_dvd] = value
    option[:cmd] = "enject"
  end
  
  #关闭光驱
  opts.on('-c close_dvd', '--close close_dvd', 'mount all dvd drive') do |value|
    option[:close_dvd] = value
    option[:cmd] = "close"
  end

  #磁盘索引号
  opts.on('-i diskindex', '--index diskindex', 'Specify dvd index') do |value|
    option[:diskindex] = value
  end

end.parse!
   
   $dvd = Vmopt::DVDOperation.new

   case option[:cmd]
   when "query" 
     if option[:queryopt] == "dvd_information"
       $dvd.get_dvd_information
     elsif option[:queryopt] == "read_dvd"
     	 unless option[:disksymbol].nil?
     	   $dvd.read_dvd(option[:disksymbol])
     	   return ;
     	 end
     	 puts "please check the params, disksymbol is nil"
     end

   when "disable"
   	 if option[:disable_opt] == "disable_all_dvd"
   	 	 $dvd.disable_all_dvd
   	 elsif option[:disable_opt] == "disable_index_dvd"
   	 	 unless option[:diskindex].nil?
     	   $dvd.disable_index_dvd(option[:diskindex])
     	   return ;
     	 end
     	 puts "please check the params, diskindex is nil"
     end
   
   when "enable"
   	 if option[:enabl_all_disks] = "enable_all_dvd"
   	 	 $dvd.enable_all_dvd
   	 else
   	 	 puts "please check the params."
   	 end
   
   when "remove"
   	 if option[:remov_disks] == "remove_all_dvd"
   	   $dvd.remove_all_dvd
   	 elsif option[:remov_disks] == "remove_index_dvd"
   	 	 unless option[:diskindex].nil?
   	 	 	 $dvd.remove_index_dvd(option[:diskindex])
   	 	   return ;
   	 	 end
   	 	 puts "please check the params."
   	 end

   when "mount"
   	 if option[:mount_all_dvd] == "mount_all_dvd"
   	   $dvd.mount_all_dvd
   	 else
   	 	 puts "please check the params."
   	 end 

   when "enject"
   	 if option[:enject_dvd] == "enject_dvd"
   	   $dvd.enject_dvd
   	 else
   	 	 puts "please check the params."
   	 end 
   	
   when "close"
   	 if option[:close_dvd] == "close_dvd"
   	   $dvd.close_dvd
   	 else
   	 	 puts "please check the params."
   	 end 	
   
   else
        system("vmdvd -help");
   end

   	

