{vec2} = require 'gl-matrix'

# How does it function
# On screen you see a bunch of nicely connected walls
# that is one PIXI.Graphics object with alot of lineTo stuff.
# The corners of the walls are respresented in a dictionary keyed on their position.
# When the user drags a corner he is actually dragging an Interactive DisplayObject
# on each drag event the key is changed too, before that though you'll have to look up all walls and see which are attached
# <do this earlier it never changes>
# per corner you have two walls attached, you need to know which endpoints of the both walls we share coord with


# The interactive layer sits on top of the drawn walls,
# it has interactive polygons in DisplayObjects for walls
# and interactive Circles in DisplayObject for corners
# it needs to talk very directly to the drawn walls which is offcourse dumb.

polyToPIXIPoly = (arr)->
    pixiArr = []
    for elem,i in arr by 2
        pixiArr.push new PIXI.Point(arr[i],arr[i+1])
    new PIXI.Polygon(pixiArr)
    
class InteractiveLayer extends PIXI.DisplayObjectContainer
    constructor : (@walls) ->
        super()
        @corners = {}
        @container = new PIXI.Graphics()
        @cornerLayer = new PIXI.DisplayObjectContainer()
        @wallOverlayLayer = new PIXI.Graphics()
        @container.addChild @wallOverlayLayer
        @container.addChild @cornerLayer
        
    addCorner: (x,y) ->
        if @corners["#{x},#{y}"]
          return @corners["#{x},#{y}"]
        else
          @corners["#{x},#{y}"] = new WallCorner(x,y)
          return @corners["#{x},#{y}"]
          
    getCorners : ->
        v for k, v of @corners
    

    addWall : (wall) ->
        corner1 = @addCorner(wall.A[0],wall.A[1])
        corner2 = @addCorner(wall.B[0],wall.B[1])
        corner1.addEdge wall
        corner2.addEdge wall

    renderWallOverlays: ()->
        @wallOverlayLayer.clear()
        @wallOverlayLayer.beginFill(0xffff00, 0.5)
        @wallOverlayLayer.lineStyle(2,0x000000,0.5)

        for w in @walls
            @wallOverlayLayer.drawPath(w.polygon())

    wallOverlay: (elem,id) ->
        elem.interactive = true
        elem.mouseover = => console.log 'hiya wall',id
        
        elem.mousedown = (data) =>
            @hasReleased = false
            console.log 'down',id
            elem.isDowned = true
            elem.dx = elem.position.x - data.originalEvent.clientX
            elem.dy = elem.position.y - data.originalEvent.clientY
        elem.mouseup = elem.mouseupoutside = =>
            elem.isDowned = false
        elem.mousemove = (data) =>
            if elem.isDowned
                newX = data.originalEvent.clientX + elem.dx
                newY = data.originalEvent.clientY + elem.dy
                diffx = newX - elem.position.x
                diffy = newY - elem.position.y
                #console.log elem.wall
                
                #@corners[]
                corner1 = @corners["#{elem.wall.A[0]},#{elem.wall.A[1]}"]
                corner2 = @corners["#{elem.wall.B[0]},#{elem.wall.B[1]}"]
                #@updateCornerPostion
                #console.log corner1,corner2
                #console.log corner1.edges
                #console.log elem
                
                # for wall in corner1.edges
                #     console.log wall.A[0],corner1.x,corner1.y
                #     if wall.A[0] is corner1.x and wall.A[1] is corner1.y
                #         wall.A[0] += diffx
                #         wall.A[1] += diffy
                #     if wall.B[0] is corner1.x and wall.B[1] is corner1.y
                #         wall.B[0] += diffx
                #         wall.B[1] += diffy
                # for wall in corner2.edges
                #     if wall.A[0] is corner2.x and wall.A[1] is corner2.y
                #         wall.A[0] += diffx
                #         wall.A[1] += diffy
                #     if wall.B[0] is corner2.x and wall.B[1] is corner2.y
                #         wall.B[0] += diffx
                #         wall.B[1] += diffy
                #elem.position.x = newX
                #elem.position.y = newY
                
                #get all walls that use any of these 
                #console.log diffx,diffy
                elem.wall.A[0]+= diffx
                elem.wall.A[1]+= diffy
                elem.wall.B[0]+= diffx
                elem.wall.B[1]+= diffy
                @renderConnectedWalls()
                @renderWallOverlays()
                #@updateWallOverlays()
                
    updateWallOverlays:()->
        for w,i in @walls
            canvas = new PIXI.Graphics()
            canvas.beginFill(0xaaaaff)
            canvas.drawPath(w.polygon())
            elem = @wallOverlayLayer.children[i]
            elem.removeChildAt(0)
            elem.addChild canvas
            elem.hitArea = polyToPIXIPoly w.polygon()
            elem.position = new PIXI.Point(0,0)
            
    createInteractiveWallOverlays: ()->
        counter = 0
        for w in @walls
            elem = new PIXI.DisplayObjectContainer()
            elem.wall = w
            canvas = new PIXI.Graphics()
            canvas.beginFill(0xaaaaff)
            canvas.drawPath(w.polygon())
            elem.id = counter
            elem.hitArea = polyToPIXIPoly w.polygon()
            elem.position = new PIXI.Point(0,0)
            @wallOverlay(elem, counter)
            elem.addChild canvas
            @wallOverlayLayer.addChild elem
            counter++
            
    renderConnectedWalls: ()->
        @container.clear()
        @container.lineStyle(10,0xffffff)
        @container.moveTo(@walls[0].A[0],@walls[0].A[1])
        for w in @walls
            #console.log 'doingthis/'
            @container.lineTo(w.B[0], w.B[1])

    createInteractiveCornerCircles: ()->
        counter = 0
        for corner in @getCorners()
            ID = counter
            elem = new PIXI.DisplayObjectContainer()
            elem.hitArea= new PIXI.Circle(0,0,20)
            elem.position = new PIXI.Point(corner.x,corner.y)
            elem.corner = corner
            @cornerCircle(elem, ID)

            canv = new PIXI.Graphics()
            canv.lineStyle(10,0xff2288)
            canv.drawCircle(0,0,20)
            elem.addChild canv
            @cornerLayer.addChild elem
            counter++
            
    updateCornerPosition: (oldP, newP) ->
        value = @corners["#{oldP.x},#{oldP.y}"]
        delete @corners["#{oldP.x},#{oldP.y}"]# = null
        value.x = newP.x
        value.y = newP.y
        @corners["#{newP.x},#{newP.y}"] = value
                
    cornerCircle: (elem, id) ->
        elem.interactive = true
        elem.mouseover = => console.log 'hiya corner ',id
        
        elem.mousedown = (data) =>
            @hasReleased = false
            #console.log 'down',id
            elem.isDowned = true
            elem.dx = elem.position.x - data.originalEvent.clientX
            elem.dy = elem.position.y - data.originalEvent.clientY
        elem.mouseup = =>
            elem.isDowned = false
        elem.mouseupoutside = =>
            #console.log 'like apples?',id
            elem.isDowned = false
        elem.mousemove = (data) =>
            if elem.isDowned
                newX = data.originalEvent.clientX + elem.dx
                newY = data.originalEvent.clientY + elem.dy
                
                #console.log elem.corner.edges
           
                # now you should:
                # get the correct wallcorner from the dictionary and all walls that use it.
                for wall in elem.corner.edges
                    if wall.A[0] is elem.position.x and wall.A[1] is elem.position.y
                        wall.A[0] = newX
                        wall.A[1] = newY
                    if wall.B[0] is elem.position.x and wall.B[1] is elem.position.y
                        wall.B[0] = newX
                        wall.B[1] = newY
                @updateCornerPosition(elem.position,{x:newX,y:newY})
                elem.position.x = newX
                elem.position.y = newY

                @renderConnectedWalls()
                @renderWallOverlays()
                @updateWallOverlays()


class Floorplan
    constructor: ()->
        @walls = []
        @layer = new InteractiveLayer(@walls)
     
    addWall: (p1, p2, thickness) ->
        @lastP = p2
        @lastThick = thickness
        wall = new Wall(vec2.fromValues(p1.x,p1.y),vec2.fromValues(p2.x,p2.y),thickness)
        @layer.addWall(wall)
        @walls.push(wall)
    wallTo: (p2) ->
        @addWall(@lastP, p2, @lastThick)
         
    

class WallCorner
    constructor: (@x,@y) ->
        @edges = []
    addEdge : (edge) ->
        @edges.push edge
    getAdjacent: (fromEdge) ->
        (edge for edge in @edges when fromEdge isnt edge)

        
        
class Wall
    constructor: (@A, @B, @thickness) ->
    polygon: ->
        s1 = (new WallEdge(@A, @B, @thickness)).offset()
        s2 = (new WallEdge(@B, @A, @thickness)).offset()
        [s1.a[0],s1.a[1],s1.b[0],s1.b[1],s2.a[0],s2.a[1],s2.b[0],s2.b[1],s1.a[0],s1.a[1]]

class WallEdge
    constructor: (@A, @B, @thickness) ->

    normal:->
        d = vec2.create()
        vec2.subtract(d, @A, @B)
        vec2.normalize(d, d)
        vec2.fromValues(-d[1], d[0])

    angle: ->
        dx = @A[0] - @B[0]
        dy = @A[1] - @B[1]
        Math.atan2(dy, dx)*(180/Math.PI)
        
    offset:->
        n = @normal()
        t = @thickness / 2
        xa = @A[0] + n[0] * t
        ya = @A[1] + n[1] * t
        xb = @B[0] + n[0] * t
        yb = @B[1] + n[1] * t
        {a:vec2.fromValues(xa, ya), b:vec2.fromValues(xb, yb)}        


animate = ->
    stats.begin()
    requestAnimFrame animate
    renderer.render stage
    stats.end()
    
stage = new PIXI.Stage(0xff0000)

renderer = new PIXI.WebGLRenderer(window.innerWidth, window.innerHeight, null, false, true)
#renderer = new PIXI.CanvasRenderer(window.innerWidth, window.innerHeight, null,false, false)
document.body.appendChild(renderer.view)

stats = new Stats()
stats.setMode(0)
stats.domElement.style.position = 'absolute'
stats.domElement.style.right = '300px'
stats.domElement.style.top = '0px'
document.body.appendChild(stats.domElement)



graphics = new PIXI.Graphics()
floorplan = new Floorplan(stage)

p1 = {x:100, y:100}
p2 = {x:300, y:200}
p3 = {x:400, y:220}
p4 = {x:100, y:420}

thick = 10

floorplan.addWall({x:100,y:100},{x:100,y:200},thick)
floorplan.wallTo({x:300,y:500})
floorplan.wallTo({x:500,y:500})
floorplan.wallTo({x:600,y:500})
floorplan.wallTo({x:700,y:500})
floorplan.wallTo({x:100,y:100})

graphics.lineStyle(thick,0x00ff00)

floorplan.layer.renderConnectedWalls()
#graphics.lineStyle(3,0x000000,0.5)
#graphics.beginFill(0xffffff, 0.5)
#floorplan.layer.renderWallOverlays()
floorplan.layer.createInteractiveCornerCircles()
floorplan.layer.createInteractiveWallOverlays()
graphics.addChild floorplan.layer.container
#graphics.drawPath(poly)

stage.addChild graphics
#renderer.render(stage)
requestAnimFrame( animate)

