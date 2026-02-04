set dotenv-load

PROJ := `uv version | awk '{print $1}'`
VER := `uv version | awk '{print $NF}'`
TOKEN := env("UV_PUBLISH_TOKEN")


# defaults to publish
all: publish

# display information about the project
[group('util')]
info:
    @echo Project: {{PROJ}}
    @echo Version: {{VER}}
    @echo Git Branch: $(git rev-parse --abbrev-ref HEAD)
    @echo Git HEAD: $(git rev-parse --short HEAD)
    @echo Git Tag: $(git describe --tags --abbrev=0) \($(git rev-parse --short $(git describe --tags --abbrev=0)^{commit})\)
    @echo Git Status: $(git status --porcelain | wc -l) uncommitted
    @echo Git Origin: $(git config --get remote.origin.url)
    @echo Recent commits:
    @git --no-pager log --oneline --graph --decorate -10

# build using uv
[group('build')]
build:
    uv build

# build standalone windows exe using pyinstaller
[group('build')]
pyinstaller: build
    python -m PyInstaller -F {{PROJ}}.py

# create zip file for the standalone windows exe distrubution
[group('build')]
zip: pyinstaller
    zip -j "dist/{{PROJ}}-{{VER}}-win_x64.zip" dist/{{PROJ}}.exe

# create sha256 checksums for all distribution files and save them to a text file
[group('build')]
hash: zip
    sha256sum dist/{{PROJ}}-{{VER}}-win_x64.zip > dist/checksums-{{VER}}.txt
    sha256sum dist/{{PROJ}}-{{VER}}.tar.gz >> dist/checksums-{{VER}}.txt
    sha256sum dist/{{PROJ}}-{{VER}}-py3-none-any.whl >> dist/checksums-{{VER}}.txt
    cat dist/checksums-{{VER}}.txt

# create a github release and publosh the distribution files
[group('deploy')]
release: hash
    git tag -a "v{{VER}}" -m "Release v{{VER}}"
    git push origin "v{{VER}}"
    gh release create "v{{VER}}" dist/{{PROJ}}-{{VER}}-win_x64.zip dist/{{PROJ}}-{{VER}}.tar.gz dist/{{PROJ}}-{{VER}}-py3-none-any.whl dist/checksums-{{VER}}.txt --title "v{{VER}}" --generate-notes

# publish the project to pypi using uv
[group('deploy')]
publish: build
    uv publish --token {{TOKEN}}

# bump the project version (this updates project.toml as well as the main python file) Takes an argument: [major, minor, patch]
[group('util')]
bump part="patch":
    @echo Current version: {{VER}}
    bmpv {{PROJ}}.py {{part}}
    uv version --bump {{part}}

# clean up build artifacts
[group('util')]
clean:
    -rm -rf build 
    -rm -rf dist 
    -rm -rf __pycache__
