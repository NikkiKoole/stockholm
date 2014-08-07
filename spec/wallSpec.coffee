{Floorplan} = require '../src/floorplan'
{FloorplanEditor} = require '../src/editor'

global.PIXI ={
    DisplayObjectContainer:class DisplayObjectContainer
        constructor: ->
            @children = []
        addChild:(child)->
            @children.push child
    Circle:class Circle
    Rectangle:class Rectangle
    Point:class Point
    Polygon:class Polygon
    Graphics:class Graphics
        constructor:->
            @position = {x:0,y:0}
        beginFill:->
        endFill:->
        drawPath:->
        lineStyle:->
        drawCircle:->
        clear:->
        }


describe 'the Floorplan Editor', ->
    editor = null
    floorplan = null
    beforeEach ->
        editor = new FloorplanEditor() 
        
    it 'constructs', ->
        expect(editor).toBeTruthy()
    it 'is informed about the adding of corners', ->
        spyOn(editor, 'onAddedCorner')
        wall = editor.addWall({x:100,y:100},{x:200,y:200},10)
        expect(editor.onAddedCorner).toHaveBeenCalled()
    it 'adds its own representations of walls and corners and bind them to the ones in floorplan', ->
        wall = editor.addWall({x:100,y:100},{x:200,y:200},10)
        cornerOverlays = editor.layer.cornerOverlays
        wallOverlays = editor.layer.wallOverlays
        expect(cornerOverlays.length).toBe(2)
        expect(wallOverlays.length).toBe(1)
        expect(wallOverlays[0].original).toBe(wall)
    it 'changes values in the original floorplan when one of its walloverlays is moved',->
        wall = editor.addWall({x:100,y:100},{x:200,y:200},10)
        wallOverlays = editor.layer.wallOverlays
        overlay = wallOverlays[0]
        editor.moveWallOverlay(overlay, 20,20)
        gotMovedWall = editor.plan.getWall({x:120,y:120},{x:220,y:220})
        expect(gotMovedWall).toBeTruthy()
        neverGotWall = editor.plan.getWall({x:100,y:100},{x:200,y:200})
        expect(neverGotWall).toBeFalsy()
    it 'changes values in the original floorplan when one of its corneroverlays is moved', ->
        wall = editor.addWall({x:100,y:100},{x:200,y:200},10)
        corner1 = editor.plan.corners[0]
        corner2 = editor.plan.corners[1]
        cornerOverlay1 = editor.layer.cornerOverlays[0]
        cornerOverlay2 = editor.layer.cornerOverlays[1]
        expect(cornerOverlay1.original).toBe corner1
        expect(cornerOverlay2.original).toBe corner2
        editor.moveCornerOverlay(cornerOverlay1, 20, 20)
        gotMovedWall = editor.plan.getWall({x:120,y:120},{x:200,y:200})
        expect(gotMovedWall).toBeTruthy()
        

describe 'the Floorplan',->
    floorplan = null
    beforeEach ->
        floorplan = new Floorplan()
    it 'constructs', ->
        expect(floorplan).toBeTruthy()
    it 'has an api for adding walls (which might share corners)', ->
        expect(floorplan.addWall).toBeTruthy()
        wall = floorplan.addWall({x:100,y:100},{x:200,y:200},10)
        expect(wall).toBeTruthy()
        expect(floorplan.corners.length).toBe(2)
        wall = floorplan.addWall({x:200,y:200},{x:200,y:300},10)
        expect(floorplan.corners.length).toBe(3)
        gotWall = floorplan.getWall({x:200,y:300},{x:200,y:200})
        expect(gotWall).toBeTruthy()
        # I expect not to find the walls at some crazy position
        neverGotWall = floorplan.getWall({x:92138173200,y:300},{x:200,y:200})
        expect(neverGotWall).toBeFalsy()
        
    it 'has an api for moving walls in relative position',->
        expect(floorplan.moveWall).toBeTruthy()
        wall = floorplan.addWall({x:100,y:100},{x:200,y:200},10)
        floorplan.moveWall(wall, 20,20)
        gotMovedWall = floorplan.getWall({x:120,y:120},{x:220,y:220})
        expect(gotMovedWall).toBeTruthy()
        
    it 'has an api for moving 1 corner/endpoint of a wall',->
        expect(floorplan.moveCorner).toBeTruthy()
        wall1 = floorplan.addWall({x:100,y:100},{x:200,y:200},10)
        wall2 = floorplan.addWall({x:100,y:100},{x:300,y:200},10)
        corner = floorplan._getCornerAtPoint({x:100,y:100})
        floorplan.moveCorner(corner, 20, 20)
        expect(floorplan._getCornerAtPoint({x:120,y:120})).toBeTruthy()
        gotWall1 = floorplan.getWall({x:120,y:120},{x:200,y:200})
        gotWall2 = floorplan.getWall({x:120,y:120},{x:300,y:200})
        expect(gotWall1).toBeTruthy()
        expect(gotWall2).toBeTruthy()
        # I expect not to find the walls at their old position
        neverGotWall1 = floorplan.getWall({x:100,y:100},{x:200,y:200})
        neverGotWall2 = floorplan.getWall({x:100,y:100},{x:300,y:200})
        expect(neverGotWall1).toBeFalsy()
        expect(neverGotWall2).toBeFalsy()
