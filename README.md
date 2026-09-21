# 残響回線 / NULL RELAY

Windows向け、完全2Dピクセルアートの高速アクション。Godot 4.5.2 / GDScript。
正本リポジトリ: https://github.com/s8ev/adamapp

**現在はPHASE 0の設計・起動基盤です。戦闘やMISSION 01はまだ実装していません。**
実装状況と検証結果は [ROADMAP](docs/ROADMAP.md) と [QA_REPORT](docs/QA_REPORT.md) に記録します。

## 起動

Godot **4.5.2 Standard**で `project.godot` を読み込み、F6ではなく **F5**。
Windowsで同梱の開発用エンジンを取得する場合:

```powershell
powershell -ExecutionPolicy Bypass -File tools/setup.ps1
powershell -ExecutionPolicy Bypass -File tools/run.ps1
```

`起動チェック` は入力と描画を検証する開発用画面です。ゲーム本編ではありません。
マウス、方向キー、Enter、Escに対応。F11でフルスクリーン切替。
設定画面で解像度、VSync、FPS上限を変更できます。

## 検証

```powershell
powershell -ExecutionPolicy Bypass -File tools/test.ps1
```

Godotのインポート、GDScriptのテスト、起動スモークテストを実行します。
追加のエディタープラグインやPythonパッケージは不要です。
`.tools`（エンジン）、`.godot`（キャッシュ）、`artifacts`（検証出力）はGit対象外。
Windows完成版のEXEはPHASE 17で制作します。現在の配布物は開発プロジェクトです。

## 設計

- [現状監査とフォルダ構成](docs/REPOSITORY_AUDIT.md)
- [ゲーム設計](docs/GAME_DESIGN.md) / [物語（ネタバレあり）](docs/STORY.md)
- [キャラクター](docs/CHARACTERS.md) / [戦闘](docs/COMBAT.md)
- [武器](docs/WEAPONS.md) / [敵](docs/ENEMIES.md) / [ステージ](docs/LEVELS.md)
- [アート](docs/ART_STYLE.md) / [音](docs/AUDIO.md) / [技術](docs/TECHNICAL.md)
- [ロードマップ](docs/ROADMAP.md) / [QA計画](docs/QA_PLAN.md) / [変更履歴](docs/CHANGELOG.md)

原作ゲームの画像・音・台詞は使用しません。外部素材の出典は [ASSET_LICENSES](docs/ASSET_LICENSES.md)。
原作コード・物語・図形アートのライセンスは未指定です。公開リポジトリであることを理由に
OSSライセンスを自動付与しません。フォントには同梱のSIL OFLが適用されます。
