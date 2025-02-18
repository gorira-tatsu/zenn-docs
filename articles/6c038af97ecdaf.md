---
title: "暦本先生のVoice2Memoを試してみる"
emoji: "🎙️"
type: "idea" # tech: 技術記事 / idea: アイデア
topics: ["Whisper", "音声認識", "OpenAI"]
published: true
---

## 導入

最近「2035年の人間の条件」という本を読んでいたら、こんな話が取り上げられてました。

> 暦本　(前略) 僕も少し前から、音声で文章を書いています。最初からキーボードを打つのは面倒くさいので、とりあえず「いま僕が考えているのはこんなこととかあんなこととかだ」と思いのたけを数分間ぐらいかけて吐き出すんですね。それぐらいの時間でも、喋ると原稿用紙何枚分にもなっちゃう。キーボードでそれだけ書こうと思ったら、何時間もかかるでしょ。
>
>  落合　とりあえず喋りきってからあとでまとめたほうが早いですよね。 
>
> 暦本　そう。だけど、前は喋ったものを手で編集していたんだけど、いまは口述したデータを「はい、これを論文のアブストラクトにしてください」とチャットＧＰＴに渡しちゃう。それで出てきたものを自分で直すんです。

暦本純一; 落合陽一. 2035年の人間の条件（マガジンハウス新書） (Japanese Edition) (pp. 23-24). 株式会社マガジンハウス. Kindle Edition. 

へ〜と思っていたら、先日、暦本純一先生がこのようなツイートをされていました。ちょうどソースコードも公開されていたので、自分で試してみました。ちょっとだけ導入にハマったので備忘録的にメモ。これで高校の通学時間の独り言が文字起こしされそうなので、結構楽しくなりそうな気が。

https://x.com/rkmt/status/1888453949377958073

https://x.com/rkmt/status/1888574570866802693



## whisper.cppをBuildする

本記事では、pip経由でwhisper-cliをインストールせず、whisper.cppのBuild経由で導入しました(後者しか試していませんが、問題なく動作しています)。

https://github.com/ggerganov/whisper.cpp

cmakeとffmpegをinstall済みであること

:::details cmakeとffmpegのinstall

```shell
brew install cmake ffmpeg
```

:::

```shell
git clone https://github.com/ggerganov/whisper.cpp.git
cd whisper.cpp
bash ./models/download-ggml-model.sh large-v3-turbo
cmake -B build
cmake --build build --config Release
./build/bin/whisper-cli -m ./models/ggml-large-v3-turbo.bin -f samples/jfk.wav
```



```shell
(中略)

system_info: n_threads = 4 / 8 | AVX = 0 | AVX2 = 0 | AVX512 = 0 | FMA = 0 | NEON = 1 | ARM_FMA = 1 | F16C = 0 | FP16_VA = 1 | WASM_SIMD = 0 | SSE3 = 0 | SSSE3 = 0 | VSX = 0 | COREML = 0 | OPENVINO = 0 |

main: processing 'samples/jfk.wav' (176000 samples, 11.0 sec), 4 threads, 1 processors, 5 beams + best of 5, lang = en, task = transcribe, timestamps = 1 ...


[00:00:00.300 --> 00:00:09.360]   And so, my fellow Americans, ask not what your country can do for you, ask what you can
[00:00:09.360 --> 00:00:11.000]   do for your country.


whisper_print_timings:     load time =  2663.53 ms
whisper_print_timings:     fallbacks =   0 p /   0 h
whisper_print_timings:      mel time =    12.09 ms
whisper_print_timings:   sample time =    72.01 ms /   148 runs (    0.49 ms per run)
whisper_print_timings:   encode time =  4922.42 ms /     1 runs ( 4922.42 ms per run)
whisper_print_timings:   decode time =     0.00 ms /     1 runs (    0.00 ms per run)
whisper_print_timings:   batchd time =   461.18 ms /   146 runs (    3.16 ms per run)
whisper_print_timings:   prompt time =     0.00 ms /     1 runs (    0.00 ms per run)
whisper_print_timings:    total time =  8362.39 ms
ggml_metal_free: deallocating
```

ここで正しく以下のような出力がされていれば正しくインストールできています (文字起こしは完全一致とは限らない)。

```
[00:00:00.300 --> 00:00:09.360]   And so, my fellow Americans, ask not what your country can do for you, ask what you can
[00:00:09.360 --> 00:00:11.000]   do for your country.
```

## voice2memoの導入

```shell
git clone https://github.com/rkmt/voice2memo.git
```

暦本先生のREADME.mdに従う

https://github.com/rkmt/voice2memo/blob/main/Readme.md

:::message

Voice MemosとNotesはどちらもiCloudで同期されている必要があります。 

:::

### transcribe_and_post.shの編集　(47行目)

whisper.cppを自分でビルドしてインストールしているので、whisper-cliを絶対パスで呼び出します。必ず、whisper.cppをビルドしたあとに行います。

```transcribe_and_post.sh
/Users/${ここにUSERのPATH}/${ここにwhisper.cppのpath}/whisper.cpp/build/bin/whisper-cli "$wav_file" -of "$output_file" --model $MODEL --language ja -otxt
```



:::message alert

「49:161: execution error: Notes got an error: Can’t get account "iCloud".」 が表示された場合、NotesのiCloudの同期設定が誤っている可能性があります。

:::

## 実行

```
./transcribe_and_post.sh
```

```
(前略)
[00:00:00.000 --> 00:00:07.560]  「これはテストです。これはテストです。テスト、テスト、マイクテスト」

output_txt: saving output to '/Users/{ユーザー名}/iCloud Drive (Archive)/voice2memo/20250218 224051.txt'
(中略)
note id x-coredata://...
 ote created: 「これはテストです。これはテストです。テスト、テスト、マイクテスト」
All processing completed
```

![](https://storage.googleapis.com/zenn-user-upload/576f7d3db062-20250218.png)

保存されています。

## Tips

### Notesの保存先フォルダを指定する

Notesの保存先を指定のフォルダ配下にしたいときは、`transcribe_and_post.sh`を以下のように設定します。 (67行目-)

```
tell application "Notes"
    tell account "iCloud"
        set targetFolder to folder "{指定のフォルダ名}"
        make new note at targetFolder with properties {name:"${title}", body:"${body}"}
    end tell
end tell
```

### アクションボタンがない場合の代替

アクションボタンはiPhone 15以降で導入された物理ボタンです。そのため、SE世代等ではアクションボタンは使えません。この場合、ショートカットアプリを使うことで改善できます。まずはショートカットを以下のように設定します (保存名はお好きに)。

![](https://storage.googleapis.com/zenn-user-upload/62a3061b31c9-20250218.png)

その後、ショートカットウィジェットを以下のように設定することで、アクションボタンがなくても保存することができます。

![](https://storage.googleapis.com/zenn-user-upload/cdd67e1c7a44-20250218.jpg)

### ChatGPTに投げるところまでお任せする

APIとかをいい感じに叩いても良いのですが、ショートカットアプリがとても導入しやすいのでこちらで。

![](https://storage.googleapis.com/zenn-user-upload/6ef8ea9c57c1-20250218.jpg)

![](https://storage.googleapis.com/zenn-user-upload/47353ee4fc5e-20250218.jpg)

![](https://storage.googleapis.com/zenn-user-upload/74780514831b-20250218.jpg)

![](https://storage.googleapis.com/zenn-user-upload/56e63603d909-20250218.jpg)




## まとめ

whisper-cliをpip経由でなく、whisper.cppのBuild経由でインストールすることで導入ができました (もしpipでも導入できた方がいたらコメント等で教えてください)。
