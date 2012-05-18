package jp.co.baykraft.kdm
{
    import flash.events.Event;
    
    import jp.co.baykraft.kdm.skin.XSkinDatagrid;
    
    import mx.collections.ArrayList;
    import mx.collections.IList;
    import mx.events.FlexEvent;
    
    import spark.components.DataGrid;
    import spark.components.Scroller;
    import spark.components.gridClasses.GridColumn;
    import spark.events.GridCaretEvent;
    import spark.events.GridEvent;
    
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
        //----------------------------------
        //  初期値
        //----------------------------------

        //----------------------------------
        //  その他宣言系
        //----------------------------------

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
        //  コンストラクタ
        //----------------------------------
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
        }
        //----------------------------------
        //  override 系の処理
        //----------------------------------
        /**
         * スキンパーツが追加されたとき
         * @param partName skinpartの名前
         * @param instance skinpartのインスタンス
         */
        override protected function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);
            if (instance == grid) {
                grid.columns = super.columns;
                topGridInitializeDataGridElement();
            }
            if (lockedDataProvider) {
                if (instance == topGrid) {
                    visibleLeftGrid = true;
                    topGrid.dataProvider = lockedDataProvider;
                    topGrid.columns = super.columns;
                    topGrid.columnSeparator = columnSeparator;
                    topGrid.rowSeparator = rowSeparator;
                    topGrid.hoverIndicator = hoverIndicator;
                    topGrid.caretIndicator = caretIndicator;
                    topGrid.selectionIndicator = selectionIndicator;
                    topGridInitializeDataGridElement();
                }
                else if (instance == topScroller) {
                    visibleLeftScroller = true;
                }
            }
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
            if (topGrid)
                this.callLater(lazyGridColumnWidth);
        }
        override protected function separator_mouseUpHandler(event:GridEvent):void {
            super.separator_mouseUpHandler(event);
        }
        /**
         * 
         * @param value
         * 
         */
        override public function set nestLevel(value:int):void {
            topGridInitializeDataGridElement();
            super.nestLevel = value;
        }

        //----------------------------------
        //  public 系の処理
        //----------------------------------
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

        //----------------------------------
        //  private 系の処理
        //----------------------------------
        private function topGridInitializeDataGridElement():void {
            if (!grid || !topGrid)
                return;

            trace("grid", grid.nestLevel, "topGrid", topGrid.nestLevel, "判定", (grid.nestLevel <= topGrid.nestLevel));
            if (grid.nestLevel <= topGrid.nestLevel)
                grid.nestLevel = topGrid.nestLevel + 1;
        }
        /**
         * 
         * 
         */
        private function lazyGridColumnWidth(): void {
            if (!grid || !topGrid)
                return;

            grid.columns.toArray().forEach(function(item:*, index:int, array:Array):void{
                var col: GridColumn = topGrid.columns.toArray()[index] as GridColumn;
                col.width = GridColumn(item).width;
            });
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

    }
}