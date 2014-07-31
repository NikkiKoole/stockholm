# The newer Floorplan is properly documented

module.exports.Floorplan = class Floorplan
    constructor: ->
        @walls = []
        @corners = []
        
    addWall: (point1, point2, thickness) ->
        wall = {point1:point1, point2:point2, thickness:thickness}
        @_addCorner(point1).walls.push(wall)
        @_addCorner(point2).walls.push(wall)
        @walls.push(wall)
        wall
        
    getWall: (point1, point2) ->
        for w in @walls
            if (w.point1.x is point1.x and w.point1.y is point1.y and
                w.point2.x is point2.x and w.point2.y is point2.y) or
                (w.point2.x is point1.x and w.point2.y is point1.y and
                w.point1.x is point2.x and w.point1.y is point2.y)
                    return w
                
    moveWall: (wall, dx, dy, doCornersToo = true) ->
        #will move both its corners
        corner1 = @_getCornerAtPoint(wall.point1)
        corner2 = @_getCornerAtPoint(wall.point2)
        @moveWallCorner(corner1,dx,dy)
        @moveWallCorner(corner2,dx,dy)
        wall.point1.x += dx
        wall.point1.y += dy
        wall.point2.x += dx
        wall.point2.y += dy
        
    moveWallCorner: (corner, dx, dy) ->
        corner.x += dx
        corner.y += dy

    # private methods    
    _getCornerAtPoint: (point) ->
        for c in @corners
            if c.x is point.x and c.y is point.y
                return c
        
    _addCorner: (point) ->
        already = @_getCornerAtPoint(point)
        if already then return already

        corner = {x:point.x,y:point.y,walls:[]}
        @corners.push(corner)
        corner
