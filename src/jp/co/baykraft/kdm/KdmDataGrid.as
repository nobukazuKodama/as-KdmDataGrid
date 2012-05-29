package jp.co.baykraft.kdm
{
    import flash.events.Event;
    
    import jp.co.baykraft.kdm.skin.XSkinDatagrid;
    
    import mx.collections.ArrayList;
    import mx.collections.IList;
    import mx.events.FlexEvent;
    import mx.events.ScrollEvent;
    
    import spark.components.DataGrid;
    import spark.components.HScrollBar;
    import spark.components.Scroller;
    import spark.components.VScrollBar;
    import spark.components.gridClasses.GridColumn;
    import spark.components.supportClasses.ScrollBarBase;
    import spark.components.supportClasses.TrackBase;
    import spark.events.GridCaretEvent;
    import spark.events.GridEvent;
    import spark.events.TrackBaseEvent;
    import spark.primitives.Line;
    
    /** 
     *  spark.components.DataGrid の拡張 DataGrid <br/>
     *  <ol>
     *      <li>設定する初期値</li>
     *      <li>その他宣言系</li>
     *      <li>独自Skin コンポーネント</li>
     *      <li>コンストラクタ</li>
     *      <li>override 系の処理</li>
     *      <li>public 系の処理</li>
     *      <li>private 系の処理</li>
     *  </ol>
     *  
     *  @author nbkz.kdm
     *  @see spark.components.DataGrid.
     */
    public class KdmDataGrid extends DataGrid {
        //////////////////////////////////////////////////////////////////////
        //  初期値
        //////////////////////////////////////////////////////////////////////
        private static const DEFAULT_REQUEST_ROW_COUNT: Number = 5;  // requestedRowCount
        //////////////////////////////////////////////////////////////////////
        //  その他宣言系
        //////////////////////////////////////////////////////////////////////
        
        //////////////////////////////////////////////////////////////////////
        //  Skinparts
        //////////////////////////////////////////////////////////////////////
        //----------------------------------
        // topGrid
        //----------------------------------
        [Bindable]
        [SkinPart(required="false")]
        /**
         *  上部グリッド
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public var topGrid:spark.components.Grid;
        //----------------------------------
        //  topScroller
        //----------------------------------
        [Bindable]
        [SkinPart(required="false")]
        /**
         *  上部グリッドのスクローラ
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public var topScroller:Scroller;
        //----------------------------------
        // lockedSeparator
        //----------------------------------
        [Bindable]
        [SkinPart(required="false")]
        /**
         *  上部グリッドとのセパレータ
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public var lockedSeparator:Line;

        //////////////////////////////////////////////////////////////////////
        //  コンストラクタ
        //////////////////////////////////////////////////////////////////////
        /**
         *  レイアウトはこんな感じ↓<br/>
         *  ┌───┐<br/>
         *  │ 1 │<br/>
         *  ├───┤<br/>
         *  │ 2 │<br/>
         *  └───┘<br/>
         *  1. topGrid(topScroller) : 固定グリッド<br/>
         *  2. grid(scroller) : spark.components.DataGrid デフォルトのグリッド<br/>
         */
        public function KdmDataGrid() {
            super();
            setStyle("skinClass", XSkinDatagrid);
            requestedRowCount = DEFAULT_REQUEST_ROW_COUNT;
        }
        //////////////////////////////////////////////////////////////////////
        //  override 系の処理
        //////////////////////////////////////////////////////////////////////
        /**
         * スキンパーツが追加されたとき
         * @param partName skinpartの名前
         * @param instance skinpartのインスタンス
         */
        override protected function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);
            if (instance == grid) {
                grid.columns = super.columns;
            }
            else if (instance == scroller) {
                scroller.horizontalScrollBar.addEventListener(Event.CHANGE, scrollChangeHandler);
            }
            if (lockedDataProvider) {
                if (instance == topGrid) {
                    visibleLeftGrid = true;
                    topGrid.dataProvider = lockedDataProvider;
                    topGrid.columns = super.columns;
                    topGrid.columnSeparator = columnSeparator;
                    topGrid.rowSeparator = rowSeparator;
                    topGrid.hoverIndicator = hoverIndicator;
                    topGrid.selectionIndicator = selectionIndicator;
                }
                else if (instance == topScroller) {
                    visibleLeftScroller = true;
                }
                else if (instance == lockedSeparator) {
                    visibleLockedSeparator = true;
                }
            }
        }
        override public function set columns(value:IList):void {
            super.columns = value;
            if (topGrid) 
                topGrid.columns = super.columns;
        }
        override protected function columnHeaderGroup_clickHandler(event:GridEvent):void {
            super.columnHeaderGroup_clickHandler(event);
        }
        override protected function separator_rollOverHandler(event:GridEvent):void {
            super.separator_rollOverHandler(event);
        }
        override protected function separator_rollOutHandler(event:GridEvent):void {
            super.separator_rollOutHandler(event);
        }
        override protected function separator_mouseDownHandler(event:GridEvent):void {
            super.separator_mouseDownHandler(event);
        }
        override protected function separator_mouseDragHandler(event:GridEvent):void {
            super.separator_mouseDragHandler(event);
            if (lockedDataProvider)
                lazyGridColumnWidth();
        }
        override protected function separator_mouseUpHandler(event:GridEvent):void {
            super.separator_mouseUpHandler(event);
        }

        //////////////////////////////////////////////////////////////////////
        //  public 系の処理
        //////////////////////////////////////////////////////////////////////
        private var _lockedDataProvider: IList;
        [Bindable(event="lockedDataProviderChange")]
        public function get lockedDataProvider():IList {
            return _lockedDataProvider;
        }
        public function set lockedDataProvider(value:IList):void {
            if (_lockedDataProvider !== value) {
                _lockedDataProvider = value;
                dispatchEvent(new Event("lockedDataProviderChange"));
            }
        }
        /**
         *  type に関連づくイベントハンドラがなければ、イベントを add する
         * 
         * @param type 
         * @param listener 
         * @param useCapture 
         * @param priority 
         * @param useWeakReference 
         * 
         */
        public function hasAddEventLister(
            type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false): void {
            if (hasEventListener(type))
                return;

            addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
        /**
         *  縦スクロールバー取得
         * @return 
         * 
         */
        public function get scrollerVertivalBar(): VScrollBar {
            return scroller.verticalScrollBar;
        }

        //////////////////////////////////////////////////////////////////////
        //  private 系の処理
        //////////////////////////////////////////////////////////////////////
        private function scrollChangeHandler(event: Event): void {
            if (topGrid && lockedDataProvider.length > 0) {
                if (event.currentTarget is HScrollBar) {
                    topGrid.horizontalScrollPosition = HScrollBar(event.currentTarget).value;
                }
                else if (event.currentTarget is VScrollBar) {
                    scroller.dispatchEvent(event);
                }
            }
        }
        /**
         * lazyとかいっているけど遅延評価じゃねーし
         *  grid の各列幅を topGrid にも反映させる。
         */
        private function lazyGridColumnWidth(): void {
            if (!grid || !topGrid || !lockedDataProvider)
                return;

            var l: IList = topGrid.columns;
            // 各列に対して (forEach) 無名関数を実行
            grid.columns.toArray().forEach(function(item:*, index:int, array:Array):void{
                var w: Number = GridColumn(item).width;                 // grid の列幅
                if (isNaN(w)) {                                         // 値が NaN の時
                    w = grid.width - gridColumnsWidthPlus(l);           // grid 全体の幅より NaN を含まない幅の合計を引いたもの
                }
                var col: GridColumn = l.toArray()[index] as GridColumn;
                col.width = w;
                l.itemUpdated(col);
            });
        }
        /**
         * リスト内の width を全部足す。初期値は defNum。
         * 値が NaN だったときは足す対象としない。
         *   TODO 足す対象の properties も外から指定させるべきか？
         * @param list 計算対象リスト
         * @param defNum 初期値
         * @return 計算結果
         * 
         */
        private function gridColumnsWidthPlus(list: IList, defNum: Number=0): Number {
            // 値が NaN でないものだけをフィルターして、マップでそれぞれの width だけのリストにする。
            var array: Array = list.toArray().filter(function(item:*, index:int, array:Array):Boolean{
                return !isNaN(item.width);
            }).map(function(itm:*, idx:int, arr:Array):String{
                return itm.width;
            });
            // 「フィルタリングされたリストから値を取り出し再帰的に足していく」関数の宣言
            const ref: Function = function(def: Number, ary: Array): Number {
                if (ary.length > 0) {
                    return def + ref(ary.shift(), ary);
                }
                return def;
            };
            return ref(defNum, array);           // 宣言した関数の呼び出し
        }
        /**
         * 
         * @return 
         */
        private function get visibleLeftGrid(): Boolean {
            return topGrid.visible;
        }
        private function set visibleLeftGrid(value: Boolean): void {
            topGrid.visible = value;
            topGrid.includeInLayout = value;
        }
        /**
         * 
         * @return 
         */
        private function get visibleLeftScroller(): Boolean {
            return topScroller.visible;
        }
        private function set visibleLeftScroller(value: Boolean): void {
            topScroller.visible = value;
            topScroller.includeInLayout = value;
        }
        private function get visibleLockedSeparator():Boolean {
            return lockedSeparator.visible;
        }
        private function set visibleLockedSeparator(value: Boolean): void {
            lockedSeparator.visible = value;
            lockedSeparator.includeInLayout = value;
        }

    }
}