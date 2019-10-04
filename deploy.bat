npm run build

cd dist

git init
git add -A
git commit -m 'deploy'

git push -f https://github.com/dcode15/fantasy-hockey-stats-site.git master:gh-pages

cd -