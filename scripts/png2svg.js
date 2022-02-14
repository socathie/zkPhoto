const fs = require('fs')
const { png2svg}  = require('svg-png-converter')

async function convert() {
    let result = await png2svg({
        tracer: 'bitmap2vector',
        input: fs.readFileSync('image/output.png'),
        optimize: true
    })
    let json = {
        "image": result['content'],
        "description": "pouring latte art",
        "name": "hong kong add oil"
    }
    await fs.writeFileSync('test/token.json', JSON.stringify(json))
    await fs.writeFileSync('image/output.svg', result['content'])
}

convert()