$LOGFREQ = 1 #THIS MUST BE A FLOAT
class Pos
  attr_reader :x, :y
  def initialize(x,y)
    @x = x
    @y = y
  end
end

class LogParser 
  attr_reader :pedPos,:carPos,:lightState
  def initialize(fname)
    @pedPos=Hash.new{ |hash,value| hash[value]=Array.new}
    @carPos=Hash.new{ |hash,value| hash[value]=Array.new}
    @lightState=Hash.new
    File.open(fname).each_line.with_index do |line,index|
      
      carList = /{((?:\(.*?\))*)}.*/.match(line)[1]
      clistMatch = /\(([-\d]+),([-\d]+)\)(.*)/.match(carList)
      while clistMatch do
        @carPos[index/$LOGFREQ] << Pos.new(clistMatch[1].to_i,clistMatch[2].to_i)
        clistMatch =  /\(([-\d]+),([-\d]+)\)(.*)/.match(clistMatch[3])
      end
      
      pedList = /{.*?}{((?:\(.*?\))*)}.*/.match(line)[1]
      plistMatch = /\(([-\d]+),([-\d]+)\)(.*)/.match(pedList)
      while plistMatch do
        @pedPos[index/$LOGFREQ] << Pos.new(plistMatch[1].to_i,plistMatch[2].to_i)
        plistMatch =  /\(([-\d]+),([-\d]+)\)(.*)/.match(plistMatch[3])
      end
      
      light = /{.*?}{.*?}{(.*?)}/.match(line)[1]
      @lightState[index/$LOGFREQ] = light
    end
  end  
end

lp = LogParser.new("simLog.dat")
puts lp.pedPos
puts lp.carPos
puts lp.lightState
