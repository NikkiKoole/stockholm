{Floorplan} = require './floorplan'
WallToPoly = require './walltopoly'

polyToPIXIPoly = (arr)->
    pixiArr = []
    for elem,i in arr by 2
        pixiArr.push new PIXI.Point(arr[i],arr[i+1])
    new PIXI.Polygon(pixiArr)


class InteractiveLayer
    constructor: (@editor)->
        # both these boys later on will inherit from DisplayObjectContainer
        @wallOverlays = [] 
        @cornerOverlays = []
        @container = new PIXI.DisplayObjectContainer() 
        @wallPixi = new PIXI.DisplayObjectContainer()
        @cornerPixi = new PIXI.DisplayObjectContainer()
        @container.addChild(@wallPixi)
        @container.addChild(@cornerPixi)
        
    handleChangedWalls: (walls) ->
        for overlay in @wallOverlays
            @updateWallPoly(overlay.pixiRelated, overlay.original)
    handleChangedCorners: ()->
        for overlay in @cornerOverlays
            overlay.pixiRelated.position.x = overlay.original.x 
            overlay.pixiRelated.position.y = overlay.original.y
    updateWallPoly:(poly,original)->
        poly.clear()
        poly.beginFill(0xffffff)
        drawPoly = new WallToPoly(original).polygon()
        poly.drawPath(drawPoly)
        poly.hitArea = polyToPIXIPoly drawPoly
        #poly.lineStyle(10,0xffff00)
        #poly.lineTo(original.point1.x,original.point1.y)
        #poly.lineTo(original.point2.x,original.point2.y)

    addWallOverlay: (original)->
        poly = new PIXI.Graphics()
        poly.id = @wallPixi.children.length
        original.id = poly.id
        @wallPixi.addChild(poly)
        @_wallHelper(poly, original)
        #will add a wall to the floorplan, get it and bind a interactive polygon.
        pixiThing = {original:original,pixiRelated:poly}
        @wallOverlays.push(pixiThing)
        
    _wallHelper: (poly, original) ->
        poly.interactive = true
        poly.beginFill(0xffffff)
        drawPoly = new WallToPoly(original).polygon()
        poly.drawPath(drawPoly)
        poly.endFill()
        poly.pos = {x:0,y:0}
        poly.hitArea = polyToPIXIPoly drawPoly
        poly.position = new PIXI.Point(0,0)
        poly.mousedown = (data)->
            poly.isDowned = true
            poly.dx = poly.pos.x - data.originalEvent.clientX
            poly.dy = poly.pos.x - data.originalEvent.clientY
            
        poly.mouseup = poly.mouseupoutside = (data)->
            poly.isDowned = false
            poly.pos.x = 0
            poly.pos.y = 0
            
        poly.mousemove = (data) =>
            if poly.isDowned
                newX = data.originalEvent.clientX + poly.dx
                newY = data.originalEvent.clientY + poly.dy
                dx = newX - poly.pos.x  
                dy = newY - poly.pos.y
                poly.pos.x = newX
                poly.pos.y = newY 
                for thing in @wallOverlays
                    if thing.original.id is poly.id
                        @editor.moveWallOverlay(thing,dx,dy)
        

        
    addCornerOverlay: (original)->
        circle = new PIXI.Graphics()
        circle.original = original 
        circle.position.x = original.x
        circle.position.y = original.y
        @_cornerHelper(circle)
        circle.id = @cornerPixi.children.length
        original.id = circle.id
        @cornerPixi.addChild(circle)
        console.log @cornerPixi.children
        #will add a wall to the floorplan, get it and bind a interactive circle.
        pixiThing = {original:original,pixiRelated:circle}
        @cornerOverlays.push(pixiThing)

    # attachingEventHandlers: (elem, collection, callback) ->
    #     elem.mousedown = (data)->
    #         elem.isDowned = true
    #         elem.dx = elem.position.x - data.originalEvent.clientX
    #         elem.dy = elem.position.x - data.originalEvent.clientY
    #     elem.mouseup = elem.mouseupoutside = ->
    #         elem.isDowned = false
    #     elem.mousemove = (data) =>
    #         if elem.isDowned
    #             newX = data.originalEvent.clientX + elem.dx
    #             newY = data.originalEvent.clientY + elem.dy
    #             dx = newX - elem.original.x 
    #             dy = newY - elem.original.y 
    #             elem.position.x = newX
    #             elem.position.y = newY
    #             for thing in collection
    #                 if thing.pixiRelated.id is elem.id
    #                     if callback is 'corner'
    #                         @editor.moveCornerOverlay(thing, dx, dy)
                        

    _cornerHelper: (circle) ->
        
        circle.interactive = true
        circle.lineStyle(10,0xff00ff)
        circle.beginFill(0xbbbbbb)
        circle.drawCircle(0,0,20)
        circle.endFill()
        circle.hitArea = new PIXI.Rectangle(-20,-20,40,40)#new PIXI.Circle(0,0,20)
        #@attachingEventHandlers(circle, @cornerOverlays, 'corner')
        circle.mousedown = (data) ->
            circle.isDowned = true
            circle.dx = circle.position.x - data.originalEvent.clientX
            circle.dy = circle.position.y - data.originalEvent.clientY

            #console.log 'down',circle.id
        circle.mouseup = circle.mouseupoutside = ->
            #console.log 'up',circle.id
            circle.isDowned = false
        circle.mousemove = (data) =>
            if circle.isDowned
                newX = data.originalEvent.clientX + circle.dx
                newY = data.originalEvent.clientY + circle.dy
                dx = newX - circle.original.x 
                dy = newY - circle.original.y 
                circle.position.x = newX
                circle.position.y = newY

                for thing in @cornerOverlays
                    if thing.pixiRelated.id is circle.id
                        @editor.moveCornerOverlay(thing, dx, dy)
    
    render: ->

module.exports.FloorplanEditor = class FloorplanEditor
    constructor: ->
        @layer = new InteractiveLayer(@)
        @plan = new Floorplan(@)
    
    onAddedCorner: (corner) ->
        @layer.addCornerOverlay(corner)

    addWall: (point1, point2, thickness)->
        @lastP = point2
        @lastThickness = thickness
        wall = @plan.addWall(point1, point2, thickness)
        @layer.addWallOverlay(wall)
        wall
    wallTo: (point2) ->
        @addWall(@lastP,point2,@lastThickness)
        
    moveWallOverlay: (overlay, dx, dy) ->
        corners = @plan.moveWall overlay.original,dx,dy
        @layer.handleChangedCorners(corners)
        @layer.handleChangedWalls()

    moveCornerOverlay: (overlay, dx, dy) ->
        touchedWalls = @plan.moveCorner overlay.original, dx, dy
        #I would like to know which walls I need to rerender here.
        #console.log touchedWalls
        @layer.handleChangedWalls(touchedWalls)
