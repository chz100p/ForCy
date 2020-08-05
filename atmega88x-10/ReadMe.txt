						Osamu Tamura


		ForCy for ATmega88x ソースコード


	ファイルリスト

\ForCy
│  readme.txt
│  fcc.f			ForCy コンパイラ（中間コード）
│  fcy.exe			ForCy シミュレータ
│  go.bat			シミュレータのバッチ
│  lint.bat			スタックトレースのバッチ
│  echo.txt			以下サンプルプログラム（* は実機でのみ動作）
│  eeprom.txt		*
│  haiku.txt
│  hanoi.txt
│  hello.txt
│  intr.txt
│  jello.txt
│  lex.txt
│  mul.txt
│  music.txt			*
│  pi.txt
│  piano.txt			*
│  qsort.txt
│  queen.txt
│  rcrs.txt
│  test.txt
│  
├─at88x
│      fcc.asm		../src/at88.bat で生成したコンパイラ
│      forcyavr.aps
│      ForCyAVR.hex		ATmega88 の書き込みプログラム（ＨＥＸ形式）
│      ForCyAVR.lst
│      ForCyAVR.map
│      ForCyAVR.obj
│      main.asm		ForCy インタープリタ（アセンブラ）
│      
└─src
        at88.bat		ファームウェア用コンパイラ生成バッチ
        compiler.c		ForCy コンパイラ
        compiler.obj
        f2avr.exe		中間コード → asm 変換ツール
        fcc.f
        fcc.fc		ForCy 自己記述コンパイラ
        fcy.exe
        forcy.h		ForCy ヘッダファイル
        interprt.c		ForCy インタープリタ
        interprt.obj
        lint.c		スタックトレース機能
        lint.h
        lint.obj
        main.c
        main.obj
        makefcc.bat		自己記述コンパイラ生成バッチ
        makefile		fcy.exe 生成用
        monAT88x.fc		ATmega88 用モニタ
        


１．ForCy シミュレータの実行
　コマンドプロンプトを起動し、シミュレータとサンプルのディレクトリをカレントにする。
	go hello
などとすればＰＣ上でシミュレート実行する。


２．スタックトレース機能
　同様に、
	lint hello 1
などとすれば、各定義ワードでのスタック増減を表示する。
	lint hello 2
とすれば、すべての定義ワードのスタック増減を表示する。
{ } 内でスタックバランスが崩れると警告する（ music.txt など）。


３．ファームウェア更新（Ver. 0.88 以降）
 (1) SW1, 2 の両方を押したままRESETを押す。
 (2) '=' が表示される。
 (3) ハイパーターミナルなどで at88x/ForCyAVR.hex を送る。
　（テキストエディタで開いてコピー＆ペーストする）
 (4) =oooooooooooooo 中略 ooooooooooooooooo/ が表示される。
 (5) 再起動される。

　AVR Studio を使ってアセンブラやＣでプログラムを作成すれば、
ファームウェア更新機能でロード実行できます。プログラムメモリの
７Ｋバイトが利用できます。at88x/main.asm を参考に、７Ｋバイトめに
開始アドレスを入れてください。


４．ATmega88 への書き込み
 (1) AVR 用の書き込み器を用意する（ATmega88 対応のもの）。
 (2) ヒューズは以下を設定する。(FA, EE, E2)
	BOOTSZ=01
	BOOTRST=0
	RSTDISBL=1
	WDTON=0
	BODLEVEL=110
	CKSEL=0010 SUT=10
 (3) Boot Loader Protection Mode 2 としてロックする。
 (4) at88x/ForCyAVR.hex を書き込む。


５．システム定義ワード追加手順

●PC用コンパイラ・インタープリタの修正
・forcy.h の列挙子末尾（iENDの前）にIDを追加（iUSRCMD など）
・interprt.c に対応する処理を追加
・compiler.c のワード辞書文字列（const char *sysdic)にワード名を追加（文字列末尾にはスペースを入れること）

1. Cで記述されたPC用の ForCyコンパイラ＋インタープリタをビルド（makefile）
　Visual C++ など　→　fcy.exe


●自己記述コンパイラの修正
・fcc.fc のワード辞書文字列（sysdic)にワード名を追加（文字列末尾にはスペースを入れること）

2. fcy.exe 上で ForCy自己記述コンパイラ fcc.fc をビルド(makefcc) -> fcc.f

●改造したコンパイラを PC上で動作確認

3. fcc.f + fcy.exe（のインタープリタ部分）で ForCyプログラムをシミュレート(go *.txt)


4. ForCy自己記述コンパイラ + ATmega88用モニタ を ATmega88用にビルド(at88) -> fcc.asm

5. AVR Studio 4 で forcyavrプロジェクトを読み込む

●ATmega88 のインタープリタを拡張
・main.asmに分岐テーブルを追加し、対応する処理をアセンブラ記述

6. ビルド -> forcyavr.hex を ATmega88 へ書き込み
 

(2006/05/16)
(2007/01/27: ヒューズビットを訂正）

