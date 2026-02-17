# シミュレータ「複数マッチ」ワーニング

## ワーニング内容

```text
xcodebuild: WARNING: Using the first of multiple matching destinations:
{ platform:iOS Simulator, arch:arm64, id=..., OS:26.2, name:iPhone 17 Pro }
{ platform:iOS Simulator, arch:x86_64, id=..., OS:26.2, name:iPhone 17 Pro }
```

## 原因

同一のシミュレータデバイス（同じ id）が **arm64** と **x86_64** の両方で存在するため、`-destination` で id のみ指定すると複数の候補にマッチする。

- Apple Silicon Mac ではシミュレータが arm64（ネイティブ）で動作
- Intel Mac や Rosetta 環境では x86_64 も利用可能
- GitHub Actions の macos-26 ランナーでは、同一デバイスが両アーキテクチャで登録されている場合がある

## 対策

`-destination` に **arch=arm64** を追加して一意にする。

```bash
-destination 'platform=iOS Simulator,id=9EBC5E9F-3781-48D5-BC91-A533EAF48C34,OS=26.2,arch=arm64'
```

または name 指定の場合:

```bash
-destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2,arch=arm64'
```

## 参考

- [xcodebuild -destination](https://developer.apple.com/documentation/xcode/build-settings-reference)
- `ARCHS=arm64` と併用することで、ビルド対象アーキテクチャも明示できる
