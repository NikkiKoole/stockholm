# The newer Floorplan is properly documented

module.exports.Floorplan = class Floorplan
    constructor: (@editor)->
        @walls = []
        @corners = []
        
    addWall: (point1, point2, thickness) ->
        wall = {point1:point1, point2:point2, thickness:thickness}
        @_addCorner(point1).walls.push(wall)
        @_addCorner(point2).walls.push(wall)
        @walls.push(wall)
        wall
                
    moveWall: (wall, dx, dy) ->
        #console.log wall
        #will move both its corners
        corner1 = @_getCornerAtPoint(wall.point1)
        corner2 = @_getCornerAtPoint(wall.point2)
        @moveCorner(corner1,dx,dy)
        @moveCorner(corner2,dx,dy)
        [corner1,corner2]
        
    moveCorner: (corner, dx, dy) ->
        # find wallpoint (p1 or p2) that has this oldposition
        touchedWalls = []
        for w in corner.walls
            if corner.x is w.point1.x and corner.y is w.point1.y
                w.point1.x += dx
                w.point1.y += dy
                touchedWalls.push w
            if corner.x is w.point2.x and corner.y is w.point2.y
                w.point2.x += dx
                w.point2.y += dy
                touchedWalls.push w
                
        corner.x += dx
        corner.y += dy
        touchedWalls
        
    # private methods    
    _getCornerAtPoint: (point) ->
        #console.log point
        for c in @corners
            if c.x is point.x and c.y is point.y
                return c
        
    _addCorner: (point) ->
        already = @_getCornerAtPoint(point)
        if already then return already

        corner = {x:point.x,y:point.y,walls:[]}
        @corners.push(corner)
        # should inform the system we created & added a new corner
        # so i need *some* way of communicating
        # let's just use constructor refernce
        if @editor then @editor.onAddedCorner(corner)
        corner
        
    # probably unneeded methods. as in useful for testing.
    getWall: (point1, point2) ->
        for w in @walls
            if (w.point1.x is point1.x and w.point1.y is point1.y and
                w.point2.x is point2.x and w.point2.y is point2.y) or
                (w.point2.x is point1.x and w.point2.y is point1.y and
                w.point1.x is point2.x and w.point1.y is point2.y)
                    return w
