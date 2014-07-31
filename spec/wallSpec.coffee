{Floorplan} = require '../src/cleaner'

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
        neverGotWall = floorplan.getWall({x:92138173200,y:300},{x:200,y:200})
        expect(neverGotWall).toBeFalsy()
        
    it 'has an api for moving walls in absolute position',->
        expect(floorplan.moveWall).toBeTruthy()
        wall = floorplan.addWall({x:100,y:100},{x:200,y:200},10)
        floorplan.moveWall(wall, 20,20)
        gotMovedWall = floorplan.getWall({x:120,y:120},{x:220,y:220})
        expect(gotMovedWall).toBeTruthy()
        
        
    it 'has an api for moving 1 corner/endpoint of a wall',->
        expect(floorplan.moveWallCorner).toBeTruthy()
