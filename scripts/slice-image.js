const sharp = require('sharp');

// original image
let originalImage = 'image/input.png';

let idx = 0;

for (var i=0; i<4; i++) {
    for (var j=0; j<4; j++) {
        sharp(originalImage).extract({ width: 256, height: 256, left: j*256, top: i*256}).toFile('image/slice'+idx.toString()+'.png')
        .then(function(new_file_info) {
            console.log("Image cropped and saved");
        })
        .catch(function(err) {
            console.log("An error occured");
        });
        idx++;
    }
}
