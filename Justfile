PROJ := "bmpv"
VER := `uv version | awk '{print $NF}'`

all: release

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

bump part:
    @echo Current version: {{VER}}
    bmp {{PROJ}}.py {{part}}
    uv version --bump {{part}}
