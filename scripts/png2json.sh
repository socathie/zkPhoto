for k in {0..15}; do
    node scripts/png2json.js "slice$k"
done
