class Welford
  attr_reader :xBar, :var, :xList, :wList, :i, :min, :max
  def initialize(numAutoCor)
    @i = 0
    @xBar = 0
    @var = 0
    @xList = Array.new(numAutoCor,0)
    @wList = Array.new(numAutoCor,0)
    @numAutoCor = numAutoCor
    @min = nil
    @max = nil

  end
 
  def newData(newX)
    if @min == nil or newX < @min then
      @min = newX
    end
    if @max == nil or newX > @max then
      @max = newX
    end
    @i += 1
    @var = @var + (@i-1)/(@i.to_f)*(newX - @xBar)**2
    updateAutoCor(newX)
    @xBar = @xBar + 1/(@i.to_f)*(newX -@xBar)
  end
  
  def updateAutoCor(newX)
    if(@i == 1) then
      @xList[0] = newX
    else
      if @i < @numAutoCor then
        for j in 0..@i-1 do
          @wList[j]= wAutoCor(j,newX)
        end
      else
        for j in 0...@numAutoCor
          @wList[j] = wAutoCor(j,newX)
        end
      end
      @xList[@i%@numAutoCor]=newX
    end
  end

  def wAutoCor(index,newX)
    @wList[index] = @wList[index] + (@i-1)/(@i.to_f) * (newX-@xBar) * (@xList[(@i-index)%@numAutoCor]-@xBar)
  end
end

  
