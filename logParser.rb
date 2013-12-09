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
    clReg=/{((?:\(.*?\))*)}.*/
    clMR= /\(([-\d]+),([-\d]+)\)(.*)/
    plReg=/{.*?}{((?:\(.*?\))*)}.*/
    clMR=  /\(([-\d]+),([-\d]+)\)(.*)/
    lightRg=/{.*?}{.*?}{(.*?)}/
    File.open(fname).each_line.with_index do |line,index|
      #puts line
      carList = clReg.match(line).to_a
      if carList.length >1 then
        carList = carList[1]
        clistMatch = clMR.match(carList).to_a
        while clistMatch do
          @carPos[index/$LOGFREQ] << Pos.new(clistMatch[1].to_i,clistMatch[2].to_i)
          clistMatch = clMR.match(clistMatch[3])
        end
      end
      pedList = plReg.match(line).to_a
      if pedList.length > 1 then 
        puts pedList[1]
        pedList = pedList[1]
        plistMatch =clMR.match(pedList).to_a
        while plistMatch do
          @pedPos[index/$LOGFREQ] << Pos.new(plistMatch[1].to_i,plistMatch[2].to_i)
          plistMatch = clMR.match(plistMatch[3])
        end
      end

      light = lightRg.match(line).to_a
      if light
        light = light[1]
        @lightState[index/$LOGFREQ] = light
      end
    end
  end  
end
