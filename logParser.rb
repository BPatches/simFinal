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
    @clReg=/{((?:\(.*?\))*)}.*/
    @clMR= /\(([-\.\d]+),([-\.\d]+)\)(.*)/
    @plReg=/{.*?}{((?:\(.*?\))*)}.*/
    @clMR=  /\(([-\.\d]+),([-\.\d]+)\)(.*)/
    @lightRg=/{.*?}{.*?}{(.*?)}/
    @carPos =  Array.new
    @pedPos = Array.new
    @f = File.open(fname)
  end
  
  def advance()
    updateLists(@f.gets)
  end

  def updateLists(line)
    #puts line
    @carPos = Array.new
    @pedPos =  Array.new
    carList = @clReg.match(line).to_a
    if carList.length >1 then
      carList = carList[1]
      clistMatch = @clMR.match(carList).to_a
      while clistMatch do
        @carPos << Pos.new(clistMatch[1].to_i,clistMatch[2].to_i)
        clistMatch = @clMR.match(clistMatch[3])
      end
    end
    pedList = @plReg.match(line).to_a
    if pedList.length > 1 then 
      pedList = pedList[1]
      plistMatch =@clMR.match(pedList).to_a
      while plistMatch do
        @pedPos << Pos.new(plistMatch[1].to_i,plistMatch[2].to_i)
        plistMatch = @clMR.match(plistMatch[3])
      end
    end
    
    light = @lightRg.match(line).to_a
    if light
      light = light[1]
      @lightState = light
    end
  end
end  

