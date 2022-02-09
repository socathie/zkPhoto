let k = process.argv[2]
let filepath = 'circuits/build/zkPhoto/'+k+'/public.json'

const savePixels = require('save-pixels')
const zeros = require("zeros")
const path = require('path')
const fs = require('fs')

let json = JSON.parse(fs.readFileSync(filepath))

let w = ((json.length-1) ** .5) * 2

let img = zeros([w, w, 3])

let idx = 0

let tmp

for (var j = 0; j < w; j += 2) {
    for (var i = 0; i < w; i += 2) {
        tmp = BigInt(json[idx]).toString(16).padStart(30, '0')

        img.set(i, j, 0, parseInt(tmp.slice(0, 2), 16))
        img.set(i, j, 1, parseInt(tmp.slice(2, 4), 16))
        img.set(i, j, 2, parseInt(tmp.slice(4, 6), 16))

        img.set(i + 1, j, 0, parseInt(tmp.slice(8, 10), 16))
        img.set(i + 1, j, 1, parseInt(tmp.slice(10, 12), 16))
        img.set(i + 1, j, 2, parseInt(tmp.slice(12, 14), 16))

        img.set(i, j + 1, 0, parseInt(tmp.slice(16, 18), 16))
        img.set(i, j + 1, 1, parseInt(tmp.slice(18, 20), 16))
        img.set(i, j + 1, 2, parseInt(tmp.slice(20, 22), 16))

        img.set(i + 1, j + 1, 0, parseInt(tmp.slice(24, 26), 16))
        img.set(i + 1, j + 1, 1, parseInt(tmp.slice(26, 28), 16))
        img.set(i + 1, j + 1, 2, parseInt(tmp.slice(28, 30), 16))

        idx++
    }
}

//Save to a file

var stream = fs.createWriteStream('image/output'+k+'.png')
savePixels(img, "png").pipe(stream)