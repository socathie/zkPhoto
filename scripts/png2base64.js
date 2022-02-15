var fs = require('fs');

// function to encode file data to base64 encoded string
function base64_encode(file) {
    // read binary data
    var bitmap = fs.readFileSync(file);
    // convert binary data to base64 encoded string
    return new Buffer.from(bitmap).toString('base64');
}

let json = {
    "name": "hong kong add oil",
    "description": "pouring latte art",
    "image": "data:image/png;base64,"+base64_encode('image/output.png')
}

fs.writeFileSync('test/token.json', JSON.stringify(json));