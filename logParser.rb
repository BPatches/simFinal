$LOGSTEP = .1
class Pos
  attr_reader :x, :y
  def initalize(x,y)
    @x = x
    @y = y
  end
end

class LogParser 
  def initalize(fname)
    @pedPos=Hash.new{ |hash,value| Hash[value]=List.new}
    @carPos=Hash.new{ |hash,value| Hash[value]=List.new}
    @lightState=Hash.new
    File.open(fname).each_line.with_index do |line,index|
      carList = /{(\(.*\))*}.*/.match(line).to_a
      puts carList
      pedList = /{.*?}{(\(.*\))*}.*/.match(line).to_a
      puts pedList
      @lightState[(index/$LOGSTEP) ] = /{.*?}{.*?}{(.*?)}/.match(line).to_a[0]
    end
  end  
end
