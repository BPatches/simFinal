require 'gosu'
require_relative 'logParser'
#require_relative "ContSim"
#sim = Sim.new
#log = sim.run#log is an array of a list of objects in the sim and their positions
#simLog = File.new("simLog.dat")

class XWalkDisplay < Gosu::Window
  def initialize(inF)
    @log = LogParser.new(inF)
    @simWidth = 330*7
    @simHeight = 46+10
    @winWidth = 1024
    @edge = 64
    @winHeight = (@winWidth*@simHeight.to_f/@simWidth).round

    @fps = 1
    @roadColor = Gosu::Color.argb(0x66666666)
    super(@winWidth,@winHeight+2*@edge,false,1000.0/@fps)
    @timeWarp = 1
    @pedImage = Gosu::Image.new(self,'man.bmp')
    @carImage = Gosu::Image.new(self,'car.bmp')
    @backgroundImage = Gosu::Image.new(self,'simFinal.bmp')
    @lightPosX = @winWidth/2.0-64
    @lightPosY = 0
    @lightRed = Gosu::Image.new(self,'red.bmp')
    @lightYellow = Gosu::Image.new(self,'yellow.bmp')
    @lightGreen = Gosu::Image.new(self,'green.bmp')
    #	@backgroundImage.draw(0,@edge,0)
  end
  def update
    @timeWarp.times{
      @log.advance
    }
    if button_down?(char_to_button_id('>'))
      puts " fjdnag"
      @timeWarp += 1
    elsif button_down?(char_to_button_id('<')) && @timeWarp > 1
      @timeWarp -= 1
    end
  end
  #	def needs_redraw?
  #		return @i < 3
  #	end
  def draw
    #@tempCol = Gosu::Color.argb(0xff00ff00)
    #draw_quad(0,0,@tempCol ,100,0,@tempCol ,0,100,@tempCol ,100,100,@tempCol )
    drawBackground
    drawBackgroundImage
    #@backgroundImage.draw(0,@edge,0)
    drawList(@log.pedPos,@pedImage)
    drawList(@log.carPos,@carImage)
    case @log.lightState
    when "GREEN"
      @lightGreen.draw(@lightPosX,@lightPosY,1)
    when "YELLOW"
      @lightYellow.draw(@lightPosX,@lightPosY,1)
    when "RED"
      @lightRed.draw(@lightPosX,@lightPosY,1)
    end
    #drawRoads
    #drawBlocks
    #drawXWalk
    #drawList()
    #@pedImage.draw(0,0,0)
    #for agent in log[i]
    #end
  end
  def drawBackgroundImage
    #@backgroundImage.draw(0,@edge,0)
    
    scale = @winWidth/@backgroundImage.width.to_f
    @backgroundImage.draw(0,@edge,0,scale,scale)
  end
  def drawImage(image)

  end
  def drawBackground(color = Gosu::Color.argb(0xffffffff))
    draw_quad(0,0,color,@winWidth,0,color,0,@winHeight+2*@edge,color,@winWidth,@winHeight+2*@edge,color,0,:default)
  end
  def drawRoads
    drawRoad(@winHeight/2.0,true,50)
    #drawRoad(@winWidth/2.0,false,50)
  end

  def drawRoad(pos,ew,width,color = @roadColor)
    if ew
      draw_quad(0, pos, color, @winWidth, pos, color,0, pos+width, color, @winWidth, pos+width, color,2,:default)
    else
      draw_quad(pos,0,color,pos,@winHeight,color,pos+width,0,color,pos+width,@winHeight,color,2,:default)
    end
  end
  def drawBlocks

  end
  def drawXWalk

  end
  def drawList(list,image,ped = true)
    for agent in list
      x = agent.x
      y = agent.y
      drawX = x.to_f/@simWidth*@winWidth
      drawY = y.to_f/@simHeight*@winHeight+@edge
      if ped
        drawY -= image.height
      end
      image.draw(drawX,drawY,1)
    end
  end
end
disp = XWalkDisplay.new(ARGV[0]).show
