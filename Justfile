PROJ := `uv version | awk '{print $1}'`
VER := `uv version | awk '{print $NF}'`
TOKEN := env("UV_PUBLISH_TOKEN")

all: publish

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

build:
    uv build

pyinstaller: build
    python -m PyInstaller -F {{PROJ}}.py

zip: pyinstaller
    zip -j "dist/{{PROJ}}-{{VER}}-win_x64.zip" dist/{{PROJ}}.exe

hash: zip
    sha256sum dist/{{PROJ}}-{{VER}}-win_x64.zip > dist/checksums-{{VER}}.txt
    sha256sum dist/{{PROJ}}-{{VER}}.tar.gz >> dist/checksums-{{VER}}.txt
    sha256sum dist/{{PROJ}}-{{VER}}-py3-none-any.whl >> dist/checksums-{{VER}}.txt
    cat dist/checksums-{{VER}}.txt

release: hash
    git tag -a "v{{VER}}" -m "Release v{{VER}}"
    git push origin "v{{VER}}"
    gh release create "v{{VER}}" dist/{{PROJ}}-{{VER}}-win_x64.zip dist/{{PROJ}}-{{VER}}.tar.gz dist/{{PROJ}}-{{VER}}-py3-none-any.whl dist/checksums-{{VER}}.txt --title "v{{VER}}" --generate-notes

publish: release
    uv publish --token {{TOKEN}}

bump part:
    @echo Current version: {{VER}}
    bmpv {{PROJ}}.py {{part}}
    uv version --bump {{part}}

clean:
    rm -rf build dist __pycache__
