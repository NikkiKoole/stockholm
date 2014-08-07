{FloorplanEditor} = require './editor'
{Floorplan} = require './floorplan'

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


editor = new FloorplanEditor()
stage.addChild(editor.layer.container)
firstNode = {x:parseInt(Math.random()*500),y:parseInt(Math.random()*500)}
editor.addWall(firstNode,{x:200,y:200},10)
for i in [0 .. 10]
    editor.wallTo({x:parseInt(Math.random()*500),y:parseInt(Math.random()*500)})
editor.wallTo(firstNode)
#editor.addWall({x:200,y:200},{x:200,y:300},10)
#editor.addWall({x:200,y:300},{x:200,y:500},10)


animate()
