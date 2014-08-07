{vec2} = require 'gl-matrix'

        
module.exports = class WallToPoly
    constructor: (obj) ->
        @A = vec2.fromValues(obj.point1.x,obj.point1.y)
        @B = vec2.fromValues(obj.point2.x,obj.point2.y)
        @thickness = obj.thickness
    polygon: ->
        s1 = (new Edge(@A, @B, @thickness)).offset()
        s2 = (new Edge(@B, @A, @thickness)).offset()
        [s1.a[0],s1.a[1],s1.b[0],s1.b[1],s2.a[0],s2.a[1],s2.b[0],s2.b[1],s1.a[0],s1.a[1]]

    class Edge
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
