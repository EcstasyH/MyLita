logfile = File.new("dbread.log","w+")
id = 999
logfile.syswrite(id.to_s)
logfile.close

logfile = File.new("dbread.log","r+")
idc = logfile.gets.to_i
puts idc+1