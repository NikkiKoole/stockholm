
class WallCorner
    constructor: (@x, @y)->
        @edges = []
    addEdge : (edge) ->
        @edges.push edge
    getAdjacent: (fromEdge) ->
        (edge for edge in @edges when fromEdge isnt edge)

class WallEdge
    constructor : (@corner1, @corner2, @thickness) ->
    getOther : (corner) ->
        if @sameCoords(corner, @corner1) then return @corner2
        if @sameCoords(corner, @corner2) then return @corner1
    sameCoords: (p1,p2) ->
        (p1.x is p2.x and p1.y is p2.y)

class WallGraph
  constructor : ->
    @_cornerMap = {}

  getCorners : ->
    v for k, v of @_cornerMap

  addWall: (p1, p2, thickness) ->
    corner1 = @_addCorner(p1.x, p1.y)
    corner2 = @_addCorner(p2.x, p2.y)
    edge = new WallEdge(corner1, corner2, thickness)
    corner1.addEdge edge
    corner2.addEdge edge

  _addCorner: (x, y) ->
    if @_cornerMap["#{x},#{y}"]
      return @_cornerMap["#{x},#{y}"]
    else
      @_cornerMap["#{x},#{y}"] = new WallCorner(x,y)
      return @_cornerMap["#{x},#{y}"]


module.exports = window.Floorplan = class Floorplan
    constructor: ->
        @walls = new WallGraph()
        @_lastUsedWallPoint = null
        @_lastUsedThickness = null
        @layer = new WallLayer()
        
    addWall: (p1, p2, thick) ->
        # should do alot of checking here
        @_lastUsedWallPoint = p2
        @_lastUsedThickness = thick
        @walls.addWall(p1, p2, thick)

    wallTo: (p2) ->
        @addWall(@_lastUsedWallPoint, p2, @_lastUsedThickness)

    getGraphics: (graph, graphics=new PIXI.Graphics())->
        @layer.render(graph.getCorners(),graphics,0,0,1,0xffffff)       

class WallLayer
    constructor: ->

        
    render: (corners, graphics, x, y, scale, color) ->
        graphics.beginFill 0,0
        graphics.lineStyle 1, color
        for corner in corners
          for edge1 in corner.edges
            for edge2 in corner.edges
              if edge1 isnt edge2 #and usedEdges.indexOf edge2 is -1
                console.log 'adads'
                drawn.push [edge1, corner]
                drawn.push [corner, edge2]
                graphics.moveTo((edge1.getOther(corner).x + x) * scale,(edge1.getOther(corner).y+ y)*scale)
                WallLayer._setLineThickness edge1.thickness*scale, graphics, color
                graphics.lineTo((corner.x+x)*scale, (corner.y+y)*scale)
                WallLayer._setLineThickness edge2.thickness*scale, graphics, color
                graphics.lineTo((edge2.getOther(corner).x+x)*scale,(edge2.getOther(corner).y+y)*scale)
        graphics

    @_setLineThickness : (thickness, graphics, color) ->
        if @lastThickness isnt thickness
            @lastThickness = thickness
            graphics.lineStyle @lastThickness, color
        return
