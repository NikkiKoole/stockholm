{vec2} = require 'gl-matrix'

module.exports = class Edge

    constructor: (@v1, @v2, @thickness) ->
        @offset = @_offset()

    normal: ->
        d = vec2.create()
        vec2.subtract(d, @v2.point, @v1.point)
        vec2.normalize(d, d)
        vec2.fromValues(-d[1], d[0])

    angle: ->
        dx = @v2.point[0] - @v1.point[0]
        dy = @v2.point[1] - @v1.point[1]
        Math.atan2(dy, dx)

    _offset: ->
        n = @normal()
        t = @thickness / 2
        xa = @v1.point[0] + n[0] * t
        ya = @v1.point[1] + n[1] * t
        xb = @v2.point[0] + n[0] * t
        yb = @v2.point[1] + n[1] * t
        {a:vec2.fromValues(xa, ya), b:vec2.fromValues(xb, yb)}


