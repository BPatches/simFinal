class LRandom
  attr_accessor :j
  def initialize(seed=1,numStreams=1,a = 48271,m=2**31-1)
    @seed=seed
    @numStreams=numStreams
    @numDraws=[0]
    @lastX = [seed]
    @a = a
    @m = m
    @q = (@m/@a)
    @r = @m % @a
    @alreadyWorned = {0=>[]}
    initStreams
  end
  
  def modPow(base,exponent,modulus)
    @exponent = exponent
    @modulus = modulus
    @base = base
    result = 1
    while @exponent>0
      if (@exponent % 2 == 1)
        result = (result*@base) % @modulus
      end
      @exponent = @exponent >> 1
      @base = @base**2 % @modulus
    end
    return result
  end
  
  def initStreams
    @j = @m/@numStreams
    aj = modPow(@a,@j,@m)
    while not checkMC(aj,@m) do
      @j -= 1
      aj = modPow(@a,@j,@m)
    end
    (@numStreams-1).times do |i|
      qt = (@m/aj)
      rt = @m % aj
      temp = @lastX[i]
      @lastX.push(nextInt(i,aj,qt,rt))
      @lastX[i]=temp
      @numDraws.push(0)
      @alreadyWorned[i] = []
    end
    
      @alreadyWorned[@numStreams-1] = []
  end
 
  def checkMC(a,m)
    return (m % a) < (m / a)
  end 
  
  def nextInt(streamNum=0,a=@a,q=@q,r=@r)
    if(@numDraws[streamNum]>@j )
      overlap = (streamNum + @numDraws[streamNum]/@j) % @numStreams
      if not @alreadyWorned[streamNum].include? overlap
        $stderr.puts "Stream #{streamNum} overlaping with stream #{overlap}"
        @alreadyWorned[streamNum].push(overlap)
      end
    end
    temp = @lastX[streamNum]
    if checkMC(a,@m) then
      t = a * (temp % q) - r*(temp / q)
      
      if t > 0
        @lastX[streamNum] = t
      else 
        @lastX[streamNum] = t+@m
      end
    else
      @lastX[streamNum] = (a * temp) % @m
    end
    @numDraws[streamNum] += 1
    return @lastX[streamNum]
  end

  def uniform(lowerBound = 0, upperBound = 1, streamNum = 0)
    if lowerBound >= upperBound then
      $stderr.puts "uniform lower bound not less then upper bound"
      return 0
    end
    nextI = nextInt(streamNum)
    tempF = nextI.to_f() / @m
    return tempF*(upperBound-lowerBound) + lowerBound
  end

  def equalikely(lowerBound = 0, upperBound = 2, streamNum = 0)
    return uniform(lowerBound,upperBound,streamNum).floor
  end

  def shuffle( inList, streamNum=0, upTo = -1)
    if upTo == -1 then
      iterOver = (0...inList.length)
    else
      iterOver = (0..upTo)
    end
    iterOver.each do |i|
      swapI = equalikely(i,inList.length,streamNum)
      tmp = inList[i]
      inList[i]=inList[swapI]
      inList[swapI]=tmp
    end
  end
  def exponential(mu, streamNum = 0)
    return -mu * Math.log(1-uniform(0,1,streamNum))
  end
end

