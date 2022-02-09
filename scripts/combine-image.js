const combineImage = require('combine-image')
const fs = require('fs')

let lst = []
for (var i = 0; i < 4; i++) {
  let tmp = []

  for (var j = 0; j < 4; j++) {
    let idx = i * 4 + j
    tmp.push('image/output' + idx.toString() + '.png')
  }

  lst.push(tmp)
}

function timeout(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function combine(lst) {
  for (var i = 0; i < 4; i++) {
    await combineImage(lst[i])
      .then((img) => {
        // Save image as file
        img.write('image/out' + i.toString() + '.png', () => console.log('done'));
      });
  }
  await timeout(3000);
  await combineImage(['image/out0.png', 'image/out1.png', 'image/out2.png', 'image/out3.png'], {direction: 'row'})
    .then((img) => {
      // Save image as file
      img.write('image/output.png', () => console.log('done'));
    });
}

combine(lst)
