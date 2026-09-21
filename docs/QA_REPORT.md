# QA REPORT

## PHASE 0 — 2026-09-22

環境: Windows、Godot 4.5.2.stable.official.6ce3de25a、Compatibility / OpenGL 3.3、
AMD Radeon RX 7800 XT。以下はこの環境での実行結果であり、最低スペック保証ではない。

| 項目 | 結果 |
| --- | --- |
| Godot editor import | 成功、エラーなし |
| tests/test_foundation.gd | 71項目、失敗0 |
| Main→タイトルのheadless起動 | 成功、正常終了、エラーなし |
| 実レンダラーで4画面をキャプチャ | title/settings/calibration/credits 成功 |
| 日本語/配置の画像確認 | 欠字、重なり、画面外へのはみ出しなし |
| 設定の書込・更新・バックアップ復旧 | 成功 |
| 異常値、相互排他フラグ、未来schema拒否 | 成功 |
| 7種類のFPS上限の検証・適用 | 成功。実モニターの各Hz計測とは別 |
| InputMapの存在とキーコード | 成功 |
| 3Dノード | 基本画面に存在しない |

検証コマンド: `tools/test.ps1`。画像取得: Godotで `--script res://tests/capture_scenes.gd -- --qa-isolation`。
出力は `artifacts/qa/`（Git対象外）。ユーザーの既存設定・セーブへテストは書き込まない。

修正した問題:
- エディターのユーザー領域への書込権限: エンジンのself-contained設定と適切な実行権限で検証。
- JSON数値がfloatになる再読込差: 整数検証後にintへ正規化。
- 破損JSONの読込がエンジンエラーを出す: 戻り値を扱えるJSON.parseへ変更。
- 起動シーン破棄後の終了timer: SceneTreeを捕捉するよう修正。

フォントSHA256: `3ad9af88726d42b40f7f365f0dcac785af73cf20ea6f1d5b44e57cc21150b8f1`。
公式エンジンZIPは配布元のSHA512-SUMS.txtと一致。

未検証: 全モニター/DPI/解像度の実機、360Hz体感、最小PC、初見プレイ時間。
未実装: 戦闘、会話進行、完成版セーブスロット、各ミッション、ボス、エンディング。
GitHub反映とPHASE 1の追加結果は同文書へ追記する。

