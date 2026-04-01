# Dockerfile ベースイメージ更新手順

## 概要
docker-phpenv/8.3-bookworm/Dockerfileのベースイメージを `php:8.3.13-cli-bookworm` (Debian 12) から `php:8.3-cli-trixie` (Debian 13) に更新する。

## 更新手順

### 1. ベースイメージの更新
Dockerfileの1行目を以下のように変更する：

**変更前:**
```dockerfile
FROM php:8.3.13-cli-bookworm
```

**変更後:**
```dockerfile
FROM php:8.3-cli-trixie
```

**注意:** `php:8.3.13-cli-trixie`という特定バージョンのタグは存在しないため、`php:8.3-cli-trixie`を使用する。これにより、利用可能な最新のPHP 8.3系がインストールされる。

### 2. 動作確認
以下のコマンドでDockerイメージをビルドし、正常に動作することを確認する：

```bash
cd docker-phpenv
docker build -t conchoid/docker-phpenv:v1.0.0-1-8.3.29-trixie -f 8.3-trixie/Dockerfile .
```

### 3. 互換性チェック
Debian 13への更新により、以下の点を確認する：

- パッケージの互換性（apt-getでインストールしているパッケージが利用可能か）
- phpenvの動作確認
- php-buildの動作確認
- PHP各バージョン（8.1.30, 8.2.25, 8.3.29）のインストール確認
- **注意:** PHP 8.0はEOLから1年以上経過しているため、プレインストールから除外されている
- Composerの動作確認
- docker-php-ext-installによる拡張機能（bz2, xml）のインストール確認
- OpenSSL 1.0.2uのビルドとインストール確認
- ロケール設定の確認

### 4. テスト実行
実際のPHPプロジェクトでイメージを使用し、以下を確認する：

- ビルドが正常に完了するか
- 依存関係の解決が正常に行われるか
- 実行時エラーが発生しないか
- phpenvによるPHPバージョン切り替えが正常に動作するか
- Composerによるパッケージ管理が正常に動作するか

## 注意事項
- Debian 13 (trixie) は比較的新しいリリースのため、一部のパッケージやツールのバージョンが変更されている可能性がある
- 問題が発生した場合は、パッケージのバージョン指定や代替パッケージの検討が必要になる場合がある
- **apt-getでインストールしているライブラリは必要なライブラリなので、trixieでもインストールを行う必要がある**
- **`libicu-dev`パッケージを追加する必要がある**（PHP 8.1以降のビルドに必要）
- OpenSSL 1.0.2uは古いバージョンであるため、trixieでのビルドに問題が発生する可能性がある。必要に応じてビルドオプションの調整が必要になる場合がある
- ビルド後は、phpenv、php-build、各PHPバージョン、Composer、OpenSSL 1.0.2が正常にインストールされていることを確認すること

