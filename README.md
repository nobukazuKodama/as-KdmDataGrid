KdmDataGrid
===========
概要：mx 相当とは言わないが、ドラッグ＆ドロップあたりの充実させようかと。lockedrow, lockedcollumn とかそのあたりも。フィルターとかは…しんどそうなので対応しない。

要求： 
・リストからドラッグ可能なこと 
・データグリッドのリストに対してドロップ可能なこと 
・カラム（列）固定可能なこと 
・ロウ（行）固定可能なこと 
・フッター表示可能なこと 
・Excelライクに編集可能なこと

レイアウト：
こんな感じ↓にDataGridが並ぶ 
┌───┐┌───┐ 
│ 1 ││ 3 │ 
├───┤├───┤ 
│ 2 ││ 4 │ 
└───┘└───┘ 
1(3). topGrid(topScroller) : 固定行グリッド 
2(4). grid(scroller) : spark.components.DataGrid デフォルトのグリッド

ルール： 
・spark.components.supportClasses.SkinnableContainerBase の拡張 
・skin系変数はコンストラクタより前に宣言 
・override系はコンストラクタより後に宣言 
・その他のpublic系関数はoverride系の後に宣言 
・その他のprivate系関数は最後に宣言 
・
