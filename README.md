# 残響回線 / NULL RELAY

Windows向け、完全2Dピクセルアートの高速アクション。Godot 4.5.2 / GDScript。
正本リポジトリ: https://github.com/s8ev/adamapp

**PHASE 0の起動基盤を完成し、PHASE 1の移動訓練を実装・検証しました。**
走行・ジャンプ・壁蹴り・ダッシュ・スライド・回避・マウス照準を実際に操作できます。
戦闘やMISSION 01はまだ実装していません。約60分の本編は今後の制作目標です。
実装状況と検証結果は [ROADMAP](docs/ROADMAP.md) と [QA_REPORT](docs/QA_REPORT.md) に記録します。

## 起動

Godot **4.5.2 Standard**で `project.godot` を読み込み、F6ではなく **F5**。
この作業フォルダでは **PLAY.cmdをダブルクリック**しても起動できます。
Windowsで同梱の開発用エンジンを取得する場合:

```powershell
powershell -ExecutionPolicy Bypass -File tools/setup.ps1
powershell -ExecutionPolicy Bypass -File tools/run.ps1
```

タイトルの「移動訓練を開始」で遊べます。「訓練を再開」は保存した記録点から再開します。
「入力確認」は診断専用。設定で解像度、全画面、VSync、FPS上限、音量、画面の揺れを変更できます。
音量バスは実装済みですが音素材はまだありません。

| 操作 | キー |
| --- | --- |
| 走る | A / D または左右キー |
| ジャンプ / 壁蹴り | Space（押す長さで高さを調整） |
| ダッシュ | Shift |
| スライド / 低姿勢 | S または Ctrl |
| 回避 | Alt |
| 照準 / 向き | マウス |
| 端末で衝撃演出を確認 | E |
| ポーズ / 再開 | Esc |
| 記録点へ戻る | F5（ゲームウィンドウ内） |
| 全画面 | F11 |

訓練は4記録点の短い操作コース。落下は自動復帰します。
銃の腕は照準確認用で、射撃・近接・敵への攻撃はまだ実装していません。
ポーズ中は時間と移動が停止し、フォーカスを失うと自動ポーズします。
設定と訓練記録の保存先はWindowsの `%APPDATA%/NullRelay/`。

## 検証

```powershell
powershell -ExecutionPolicy Bypass -File tools/test.ps1
```

Godotのインポート、保存/設定73項目、移動37項目×7描画条件、起動、コース通過を検証します。
FPS比較は固定deltaによる再現試験であり、360Hz実機での体感検証ではありません。
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
