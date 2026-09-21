# TECHNICAL

## 固定する環境

Godot **4.5.2 Standard / GDScript**、Compatibilityレンダラー、Windows x64優先。
最新版という主張ではなく、本プロジェクトの検証可能な固定版。変更には別コミットと回帰試験。
エンジンは公式配布ZIP＋公式SHA512を照合。エンジン本体とキャッシュをGitへ入れない。
公式資料: [4.5.2](https://godotengine.org/download/archive/4.5.2-stable/)、
[解像度](https://docs.godotengine.org/en/4.5/tutorials/rendering/multiple_resolutions.html)、
[物理補間](https://docs.godotengine.org/en/4.5/tutorials/physics/interpolation/using_physics_interpolation.html)。

## 描画・時間

640×360 viewport / aspect keep / integer scaling / nearest texture。
起動ウィンドウは1280×720。標準表示の推奨1920×1080。1440p/4Kにも整数で拡大。
小さいモニターで初回から画面外へはみ出さないよう起動寸法を選んだ。
Physics=120 tick/s、補間ON。render limit=60/120/144/165/240/360/0（Unlimited）。
VSyncは別設定。ON時にはモニター等の制限で指定FPSへ届かないことをUIで説明する。
高FPS対応は速度不変を意味し、全PCで360FPSを保証しない。
運動・クールダウン・AI判定は物理deltaで管理。照準とUIは描画delta。
時間をフレーム数で数えない。ワープ/復帰時にreset_physics_interpolationを呼ぶ。
Input.use_accumulated_input=false。押下をbufferへ記録し、次の物理tickで一度だけ消費。

## 依存の方向

現在のautoloadはSettingsManager、GameState、SaveManager、SceneRouter。
基本InputMapはproject.godotへ静的に定義する。
UI→autoload/共通UI。UI間はSceneRouter経由。描画ノードは物語や保存を知らない。
設定のディスク入出力はSettingsStoreへ分離。純粋な検証ロジックはノードに依存させない。
今後はPlayerController→WeaponSystem/DamageSystem、EnemyAI→Perception。
StoryFlagManager→GameState、SaveManager→versioned snapshot。
DialogueManagerは結果イベントを発行し、セーブや敵を直接変更しない。
グローバルEventBusに全イベントを集約せず、局所signalと必要なautoloadに留める。
型付きGDScript、snake_case、class_nameは再利用型だけ。警告を隠すため型を外さない。

## 将来の保存契約（PHASE 8）

user://saves/slot_01.json。schema_version、build_version、chapter_id、checkpoint_id、
flags、inventory、play_time_seconds、seen_dialogue、unlocked_chapters、endings、secrets。
プロフィール（結末/解禁）は進行スロットと別。設定はuser://settings.jsonで独立。
PHASE 0は別ファイルtraining_save.jsonの訓練用snapshotだけを実装。
これは本編の全保存仕様を完成したことを意味しない。
手順: 同一ディレクトリへtemp→検証→旧版をbakへ→rename。失敗は検出してUI通知。
bakから復旧できた事実を知らせる。壊れたファイルを勝手に上書きして救済を失わない。
未対応の未来schemaは上書きしない。M01は開始/重要地点/終了でオートセーブ。
戦闘途中の手動セーブは最初は作らず、チェックポイントスロット3つのLOADを提供する。
章選択用の再プレイセーブを分ける。既読スキップ、分岐、再試行で重複イベントを防ぐ。

## 会話データ契約（PHASE 6）

line_id、speaker、text_key、emotion、speed_multiplier、pause_marks、choices、conditions。
日本語本文はUTF-8。RichTextLabel.visible_charactersを使い、markupを文字数に数えない。
句読点は間を追加。完全文表示→次へは別押下。長押しで選択肢を誤決定しない。
叫び/揺れ/色をreduced effectsで抑制。感情SEは字数で無制限生成しない。

## シーン構成

boot/main→title。各画面は独立PackedScene、遷移時に旧画面を解放する。
現段階はtitle/settings/calibration/creditsだけ。未実装のNEW GAMEやCONTINUEを実装済みに見せない。
後続のmission_rootはLevel/Actors/Projectiles/Effects/Camera/CanvasLayerを分ける。
セーブ時の参照にはnode pathではなく安定したIDを使う。

## 品質と運用

変更前後にstatus/diff、Godot importとテスト。機能単位コミット。
GitHub mainを正本とし、開発ブランチ→検証→PR。force pushと無断の履歴置換はしない。
テストは専用一時ファイルを使い、実際のユーザー設定やセーブを変更しない。
初期CIはheadless import/テスト/boot。レンダー、入力体感、モニター性能は実機QAで別扱い。
画面キャプチャはGodot自身のviewportから取得。テスト用コマンドは開発用引数で明示する。
