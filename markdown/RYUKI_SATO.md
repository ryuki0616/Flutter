# Flutter

## FlutterStudio

- GUIベースでレイアウトを直感的に設定できるツール
- Flutterの言語に慣れていなくてもUI設計が簡単
- ボタンなどのウィジェットをドラッグ＆ドロップで配置できる
- 色や大きさ、位置なども簡単に変更可能
- 配置した通りのFlutterコードをコピーできる

## 公式サイト
[FlutterStudio](https://flutterstudio.app/)

- 1
- 1
    - 1
+ 1
    + 1

## マークダウンの使い方

### 見出し
```markdown
# 見出し1
## 見出し2
### 見出し3
#### 見出し4
```

### テキストの装飾
```markdown
*斜体テキスト*
_斜体テキスト_
**太字テキスト**
__太字テキスト__
***太字斜体テキスト***
~~取り消し線~~
```

### リスト
```markdown
# 順序なしリスト
- 項目1
- 項目2
  - ネストした項目
  - ネストした項目
+ 項目3
* 項目4

# 順序付きリスト
1. 最初の項目
2. 二番目の項目
3. 三番目の項目
```

### リンクと画像
```markdown
# リンク
[リンクテキスト](https://example.com)

# 画像
![代替テキスト](画像のURL)

# 画像にリンク
[![代替テキスト](画像のURL)](https://example.com)
```

### コード
```markdown
# インラインコード
`コード`

# コードブロック
```python
def hello_world():
    print("Hello, World!")
```

# シンタックスハイライト付きコードブロック
```dart
void main() {
  print('Hello Flutter!');
}
```
```

### 引用
```markdown
> これは引用文です
> 
> 複数行の引用も可能です
```

### 表
```markdown
| 列1 | 列2 | 列3 |
|-----|-----|-----|
| データ1 | データ2 | データ3 |
| データ4 | データ5 | データ6 |
```

### 水平線
```markdown
---
または
***
または
___
```

### チェックボックス
```markdown
- [x] 完了したタスク
- [ ] 未完了のタスク
- [ ] もう一つのタスク
```

### 脚注
```markdown
ここに脚注の参照[^1]を入れます。

[^1]: これは脚注の内容です。
```

### エスケープ
```markdown
\*エスケープされたアスタリスク\*
\`エスケープされたバッククォート\`
```

## パディング（padding）について

パディングとは、要素の内側の余白のことです。コンテンツ（テキストや画像など）と、その外側の枠（ボーダーや背景）との間にできるスペースを指します。

### Flutterでのパディングの使い方

Flutterでは、`Padding`ウィジェットを使って簡単にパディングを設定できます。

```dart
Padding(
  padding: EdgeInsets.all(16.0), // 全方向に16ピクセルの余白
  child: Text('パディングの例'),
)
```

#### 方向ごとに指定する場合
```dart
Padding(
  padding: EdgeInsets.only(left: 8.0, top: 16.0, right: 8.0, bottom: 16.0),
  child: Text('個別に指定したパディング'),
)
```

#### 対称に指定する場合
```dart
Padding(
  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
  child: Text('左右・上下で指定'),
)
```

### マークダウンでのパディング

マークダウン自体にはパディングを直接指定する機能はありませんが、HTMLタグを使ってスタイルを調整することは可能です。

```html
<div style="padding: 16px; background: #f0f0f0;">パディング付きのボックス</div>
```

---

## カスケード記号（..）について

カスケード記号（..）は、Dart（Flutterで使われる言語）で同じオブジェクトに対して複数の操作を連続して行うための記法です。

### 特徴
- オブジェクトを何度も変数に代入し直さずに、複数のメソッドやプロパティを呼び出せる
- コードが簡潔で読みやすくなる

### 使い方例
```dart
final controller = TextEditingController()
  ..text = '初期値'
  ..selection = TextSelection.collapsed(offset: 3);

var list = []
  ..add('A')
  ..add('B')
  ..add('C');
```

### 通常の書き方との違い
```dart
// 通常の書き方
final controller = TextEditingController();
controller.text = '初期値';
controller.selection = TextSelection.collapsed(offset: 3);

// カスケード記号を使うと
final controller = TextEditingController()
  ..text = '初期値'
  ..selection = TextSelection.collapsed(offset: 3);
```

---

## アロー関数（=>）について

アロー関数は、Dartで使える短い無名関数（ラムダ式）の書き方です。主に1行で簡潔に処理を記述したい場合に使われます。

### 特徴
- `=>`（ファットアロー）を使って、1行の処理を簡単に書ける
- 戻り値が自動的にその式の値になる
- コールバックや短い関数でよく使われる

### 使い方例
```dart
// 通常の無名関数
var list = [1, 2, 3];
var doubled = list.map((x) {
  return x * 2;
});

// アロー関数を使うと
var doubled = list.map((x) => x * 2);
```

### Flutterでの例
```dart
ElevatedButton(
  onPressed: () => print('ボタンが押されました'),
  child: Text('押す'),
)
```

### 注意点
- アロー関数は1行の式しか書けません。複数行の処理が必要な場合は通常の波括弧（{}）を使います。

```dart
// アロー関数（1行のみ）
() => print('Hello');

// 通常の無名関数（複数行）
() {
  print('Hello');
  print('World');
};
```

---

## Flutterのダイアログについて

Flutterでは、ユーザーにメッセージを表示したり、確認・選択を促すためにダイアログ（ポップアップ）を表示できます。

### 主なダイアログの種類
- **AlertDialog**：確認や警告、簡単な入力などによく使われる標準的なダイアログ
- **SimpleDialog**：選択肢をリスト表示するシンプルなダイアログ
- **showDialog**：ダイアログを表示するための関数（上記のダイアログを表示する際に使う）

### AlertDialogの例
```dart
showDialog(
  context: context,
  builder: (context) {
    return AlertDialog(
      title: Text('確認'),
      content: Text('本当に削除しますか？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            // 削除処理
            Navigator.pop(context);
          },
          child: Text('削除'),
        ),
      ],
    );
  },
);
```

### SimpleDialogの例
```dart
showDialog(
  context: context,
  builder: (context) {
    return SimpleDialog(
      title: Text('選択してください'),
      children: [
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, 'A'),
          child: Text('A'),
        ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, 'B'),
          child: Text('B'),
        ),
      ],
    );
  },
);
```

### カスタムダイアログの例
`showDialog`の`builder`で独自のWidgetを返すことで、自由にカスタマイズしたダイアログも作成できます。

```dart
showDialog(
  context: context,
  builder: (context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('カスタムダイアログ'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('閉じる'),
            ),
          ],
        ),
      ),
    );
  },
);
```

### 注意点
- `showDialog`は非同期関数なので、`await`で結果を受け取ることができます。
- ダイアログの外側をタップすると閉じるのがデフォルトですが、`barrierDismissible: false`で無効化できます。
- ダイアログ内で`Navigator.pop(context)`を呼ぶことで閉じます。

---


