require_relative 'LRandom'
class Lambda
  attr_reader :max
  def initialize(file)
    rangeLambda = {}
    last = 0
    v = 0
    @max = 0
    arrivalRates = File.new(file)
    arrivalRates.each{ |line|
      vals = line.split
      for i in (0..1)
        vals[i] = vals[i].to_i
      end
      if vals[1] > @max
        @max = vals[1]
      end
      v =vals[1]
      rangeLambda[(last...vals[0])] = vals[1]
      last = vals[0]
    }
    rangeLambda[last...1.0/0] = v
    
    @lambda = RangedHash.new(rangeLambda)
  end
  
  def [](time)
    return @lambda[time]
  end
  
  def nextArrival(time,rand,stream)
    s = time
    begin
      s = s +  rand.exponential(1.0/@max)
      u = rand.uniform(0,@max,stream)
    end while u > @lambda[s]
    return s
  end
  
end
class CustDist
def initialize(file)
    dist = {}
    sum = 0
    distF = File.new(file)
    distF.each{ |line|
      vals = line.split
      for i in (0..1)
        vals[i] = vals[i].to_i
      end
      dist[(sum...sum+vals[1])] = vals[0]
      sum+= vals[1]
    }
    @dist = RangedHash.new(dist)
  end
  def getVal(rand,stream)
  	return @dist[rand.equalikely(0,100,stream)]
  end

end
class RangedHash
  def initialize(hash)
    @hash = hash
  end
  def [](key)
    for rangeKey in @hash.keys
      if rangeKey.include?(key)
        return @hash[rangeKey]
      end
    end
  end
end
=begin
grades = {(0...60) => 'F',(60...70)=>'D',70...80 => 'C', 80...90 => 'B', 90...1.0/0 => 'A'}
test = RangedHash.new(grades)
103.times{|i|
	puts "#{i} #{test[i]}"
}
=end
#l = Lambda.new('ArrivalRate.dat')
#puts l.max
#randGen = LRandom.new
#cd = CustDist.new('carRates.dat')
#time = 0
#15.times{
#	puts time = l.nextArrival(time,randGen,0)
#}
