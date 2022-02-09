let filename = process.argv[2]

const getPixels = require('get-pixels')
const path = require('path')
const fs = require('fs')

getPixels('image/'+filename+'.png', function (err, pixels) {
  if (err) {
    console.log("Bad image path")
    return
  }
  console.log(filename+": got pixels", pixels.shape.slice())

  let x = pixels.shape[0]
  let y = pixels.shape[1]

  let rgb = []
  for (var j = 0; j < y; j++) {
    for (var i = 0; i < x; i++) {
      rgb.push([pixels.get(i, j, 0), pixels.get(i, j, 1), pixels.get(i, j, 2)]);
    }
  }

  let json = JSON.stringify({ "in": rgb })
  fs.writeFile('image/'+filename+'.json', json, (err) => {
    if (err) throw err;
    console.log(filename+': The json has been saved!');
  });
})