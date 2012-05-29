package jp.co.baykraft.kdm
{
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    import jp.co.baykraft.kdm.skin.XSkinLockedDatagrid;
    
    import mx.collections.ArrayList;
    import mx.collections.IList;
    import mx.core.DragSource;
    import mx.core.IFactory;
    import mx.core.IIMESupport;
    import mx.events.DragEvent;
    import mx.events.FlexEvent;
    import mx.managers.DragManager;
    import mx.managers.IFocusManagerComponent;
    
    import spark.components.DataGrid;
    import spark.components.Grid;
    import spark.components.Group;
    import spark.components.HScrollBar;
    import spark.components.VScrollBar;
    import spark.components.supportClasses.SkinnableContainerBase;
    import spark.events.GridEvent;
    import spark.events.GridSelectionEvent;
    
    public class LockedDataGrid extends SkinnableContainerBase implements IFocusManagerComponent, IIMESupport {
        //////////////////////////////////////////////////////////////////////
        //  初期値
        //////////////////////////////////////////////////////////////////////
        private static const DEF_LOCKED_COLUMN_COUNT: Number = 0;
        private static const MINIMAM_DATAGRID_SIZE: Number = 30;
        //////////////////////////////////////////////////////////////////////
        //  その他宣言系
        //////////////////////////////////////////////////////////////////////
        private var _leftColumn: IList;
        private var _rightColumn: IList;
        //////////////////////////////////////////////////////////////////////
        //  Skinparts
        //////////////////////////////////////////////////////////////////////
        //----------------------------------
        // leftDatagrid
        //----------------------------------
        [Bindable]
        [SkinPart(required="false")]
        /**
         *  左側のデータグリッド
         */
        public var leftDatagrid:KdmDataGrid;
        //----------------------------------
        // rightDatagrid
        //----------------------------------
        [Bindable]
        [SkinPart(required="false")]
        /**
         *  右側のデータグリッド
         */
        public var rightDatagrid:KdmDataGrid;
        //----------------------------------
        // gridSeparator
        //----------------------------------
        [Bindable]
        [SkinPart(required="false")]
        /**
         *  データグリッドのセパレータ
         */
        public var gridSeparator:spark.components.Group;

        //////////////////////////////////////////////////////////////////////
        //  コンストラクタ
        //////////////////////////////////////////////////////////////////////
        /**
         *  コンストラクタ
         */
        public function LockedDataGrid() {
            super();
            setStyle("skinClass", XSkinLockedDatagrid);
            this.addEventListener("lockedColumnCountChange", lockedColumnCountChangeHandler);
            this.addEventListener(FlexEvent.CREATION_COMPLETE, function (e: FlexEvent):void {
                trace("FlexEvent.CREATION_COMPLETE");
                dispatchEvent(new Event("lockedColumnCountChange"));
            });
        }
        //////////////////////////////////////////////////////////////////////
        //  インターフェース
        //////////////////////////////////////////////////////////////////////
        //----------------------------------
        //  enableIME
        //----------------------------------
        /**
         *  A flag that indicates whether the IME should
         *  be enabled when the component receives focus.
         *
         *  If the item editor is open, it sets this property 
         *  accordingly.
         *
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function get enableIME():Boolean {
            return false;
        }
        //----------------------------------
        //  imeMode
        //----------------------------------
        /**
         *  @private
         */
        private var _imeMode:String = null;
        [Inspectable(environment="none")]
        /**
         *  The default value for the GridColumn <code>imeMode</code> property, 
         *  which specifies the IME (Input Method Editor) mode.
         *  The IME enables users to enter text in Chinese, Japanese, and Korean.
         *  Flex sets the specified IME mode when the control gets focus,
         *  and sets it back to the previous value when the control loses focus.
         *
         * <p>The flash.system.IMEConversionMode class defines constants for the
         *  valid values for this property.
         *  You can also specify <code>null</code> to specify no IME.</p>
         *
         *  @see flash.system.IMEConversionMode
         *
         *  @default null
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function get imeMode():String {
            return _imeMode;
        }
        /**
         *  @private
         */
        public function set imeMode(value:String):void {
            _imeMode = value;
        }
        //////////////////////////////////////////////////////////////////////
        //  override 系の処理
        //////////////////////////////////////////////////////////////////////
        /**
         *  @inheritDoc
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        override protected function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);
            trace("partAdded : ", partName);
            if (instance == rightDatagrid) {
                rightDatagrid.addEventListener(GridSelectionEvent.SELECTION_CHANGING, rightDatagridSelectionHandler);
                rightDatagrid.addEventListener(GridEvent.GRID_ROLL_OVER, rightDatagridRollOverHandler);
                rightDatagrid.scrollerVertivalBar.addEventListener(Event.CHANGE, rightDatagridVScrollHandler);
                rightDatagrid.dataProvider = dataProvider;
                rightDatagrid.columns = _rightColumn;
            }
            if (lockedColumnCount > DEF_LOCKED_COLUMN_COUNT) {
                if (instance == leftDatagrid) {
                    leftDatagrid.addEventListener(GridSelectionEvent.SELECTION_CHANGING, leftDatagridSelectionHandler);
                    leftDatagrid.addEventListener(GridEvent.GRID_ROLL_OVER, leftDatagridRollOverHandler);
                    leftDatagrid.scrollerVertivalBar.addEventListener(Event.CHANGE, leftDatagridVScrollHandler);
                    leftDatagrid.dataProvider = dataProvider;
                    leftDatagrid.columns = _leftColumn;
                    visibleLeftDatagrid = true;
                }
                else if (instance == gridSeparator) {
                    visibleGridSeparator = true;
                    gridSeparator.addEventListener(MouseEvent.MOUSE_DOWN, gridSeparatorMouseDownHandler);
                }
            }
        }
        //////////////////////////////////////////////////////////////////////
        //  public 系の処理
        //////////////////////////////////////////////////////////////////////
        private var _dataProvider: IList;
        /**
         *  @copy spark.components.DataGrid#dataProvider
         */
        public function get dataProvider():IList {
            return _dataProvider;
        }
        /**
         * @private
         */
        public function set dataProvider(value:IList):void {
            if (_dataProvider !== value) {
                _dataProvider = value;
                if (leftDatagrid) {
                    leftDatagrid.dataProvider = value;
                }
                if (rightDatagrid) {
                    rightDatagrid.dataProvider = value;
                }
            }
        }

        private var _lockedDataProvider: IList;
        [Bindable(event="lockedDataProviderChange")]
        /**
         *  
         */
        public function get lockedDataProvider():IList {
            return _lockedDataProvider;
        }
        /**
         * @private
         */
        public function set lockedDataProvider(value:IList):void {
            if (_lockedDataProvider !== value) {
                _lockedDataProvider = value;
                if (leftDatagrid) {
                    leftDatagrid.lockedDataProvider = value;
                }
                if (rightDatagrid) {
                    rightDatagrid.lockedDataProvider = value;
                }
                dispatchEvent(new Event("lockedDataProviderChange"));
            }
        }

        private var _lockedColumnCount: Number = DEF_LOCKED_COLUMN_COUNT;
        [Bindable(event="lockedColumnCountChange")]
        /**
         *  
         */
        public function get lockedColumnCount():Number {
            return _lockedColumnCount;
        }
        /**
         * @private
         */
        public function set lockedColumnCount(value:Number):void {
            if (_lockedColumnCount !== value) {
                _lockedColumnCount = value;
                dispatchEvent(new Event("lockedColumnCountChange"));
            }
        }

        private var _columns: IList;
        [Bindable(event="columnsChange")]
        /**
         *  
         */
        public function get columns():IList {
            return _columns;
        }
        /**
         * @private
         */
        public function set columns(value:IList):void {
            if (_columns !== value) {
                _columns = value;
                _leftColumn = new ArrayList(value.toArray());
                _rightColumn = new ArrayList(value.toArray());
                if (leftDatagrid) {
                    leftDatagrid.columns = _leftColumn;
                }
                if (rightDatagrid) {
                    rightDatagrid.columns = _rightColumn;
                }
                dispatchEvent(new Event("columnsChange"));
            }
        }

        private var _draggableFlg: Boolean;
        [Bindable(event="draggableFlgChange")]
        /**
         *  
         */
        public function get draggableFlg():Boolean {
            return _draggableFlg;
        }
        /**
         * @private
         */
        public function set draggableFlg(value:Boolean):void {
            if (_draggableFlg !== value) {
                _draggableFlg = value;
                dispatchEvent(new Event("draggableFlgChange"));
            }
        }

        private var _dropableFlg: Boolean;
        [Bindable(event="dropableFlgChange")]
        /**
         *  
         */
        public function get dropableFlg():Boolean {
            return _dropableFlg;
        }
        /**
         * @private
         */
        public function set dropableFlg(value:Boolean):void {
            if (_dropableFlg !== value) {
                _dropableFlg = value;
                dispatchEvent(new Event("dropableFlgChange"));
            }
        }

        //////////////////////////////////////////////////////////////////////
        //  private 系の処理
        //////////////////////////////////////////////////////////////////////
        /**
         * 左側グリッドのロールオーバハンドラ
         * @param event
         * 
         */
        private function leftDatagridRollOverHandler(event: GridEvent): void {
            if (!rightDatagrid) {
                return;
            }
            rightDatagrid.grid.hoverRowIndex = event.rowIndex;
        }
        /**
         * 右側グリッドのロールオーバハンドラ
         * @param event
         * 
         */
        private function rightDatagridRollOverHandler(event: GridEvent): void {
            if (!leftDatagrid) {
                return;
            }
            leftDatagrid.grid.hoverRowIndex = event.rowIndex;
        }
        /**
         * 左側データグリッドの選択を、右側データグリッドに反映
         * @param event 
         * 
         */
        private function leftDatagridSelectionHandler(event: GridSelectionEvent): void {
            if (!rightDatagrid) {
                return;
            }
            rightDatagrid.selectedIndex = event.selectionChange.rowIndex;
        }
        /**
         * 右側データグリッドの選択を、左側データグリッドに反映
         * @param event 
         */
        private function rightDatagridSelectionHandler(event: GridSelectionEvent): void {
            if (!leftDatagrid) {
                return;
            }
            leftDatagrid.selectedIndex = event.selectionChange.rowIndex;
        }
        /**
         * 左側スクロールチェンジハンドラ
         * @param event
         * 
         */
        private function leftDatagridVScrollHandler(event: Event): void {
            if (!rightDatagrid) {
                return;
            }
            if (event.currentTarget is VScrollBar) {
                rightDatagrid.grid.verticalScrollPosition = VScrollBar(event.currentTarget).value;
            }
        }
        /**
         * 右側スクロールチェンジハンドラ
         * @param event
         * 
         */
        private function rightDatagridVScrollHandler(event: Event): void {
            if (!leftDatagrid) {
                return;
            }
            if (event.currentTarget is VScrollBar) {
                leftDatagrid.grid.verticalScrollPosition = VScrollBar(event.currentTarget).value;
            }
        }
        /**
         * 固定列の左からの列数を変更したら発するかもしれないかもしれないかもしれない
         * @param event
         * 
         */
        private function lockedColumnCountChangeHandler(event: Event): void {
            if (!columns || !_leftColumn || !_rightColumn) {
                return;
            }
            // lockedColumnCount の数がインデックスより小さいものは固定列として、左側のデータグリッド列へ
            var array: Array = columns.toArray();
            ArrayList(_leftColumn).source = array.filter(function(item:*, index:int, array:Array):Boolean{
                return index < lockedColumnCount;
            });
            // lockedColumnCount 以上のインデックスは非固定列として、右側のデータグリッド列へ
            ArrayList(_rightColumn).source = array.filter(function(item:*, index:int, array:Array):Boolean{
                return index >= lockedColumnCount;
            });
        }
        /**
         * マウスダウンハンドラ
         * ドラッグ開始処理をします。
         * @param event
         * 
         */
        private function gridSeparatorMouseDownHandler(event: MouseEvent): void {
            trace("まうすダウン");
            if (!event.buttonDown)
                return;

            // 
            if (!hasEventListener(DragEvent.DRAG_ENTER)) {
                addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
            }

            var dragInitiator:Group = Group(event.currentTarget);
            var ds:DragSource = new DragSource();
            ds.addData(dragInitiator, "_gridSeparator");
            DragManager.doDrag(dragInitiator, ds, event);
        }
        /**
         * ドラッグエンターハンドラ
         *  ドロップ対象を受け入れ可能な状態にするコンポーネントの指定をする。
         *  左側グリッドと右側グリッドに対し、イベントの付与をする
         * @param event
         * 
         */
        private function dragEnterHandler(event: DragEvent): void {
            // 判定はこのコンポーネントに独自ドロップ Enter の時に判定させないため
            if (event.dragSource.hasFormat("_gridSeparator")) {
                DragManager.acceptDragDrop(leftDatagrid);
                DragManager.acceptDragDrop(rightDatagrid);
                leftDatagrid.hasAddEventLister(DragEvent.DRAG_DROP, dragDropHandler);
                leftDatagrid.hasAddEventLister(DragEvent.DRAG_COMPLETE, dragCompleteHandler);
                rightDatagrid.hasAddEventLister(DragEvent.DRAG_DROP, dragDropHandler);
                rightDatagrid.hasAddEventLister(DragEvent.DRAG_COMPLETE, dragCompleteHandler);
            }
        }
        /**
         *  ドロップハンドラ
         *  @TODO 要検討 public にすべきか private のままでいいか？
         * @param event 
         */
        private function dragDropHandler(event: DragEvent): void {
            if (event.dragSource.hasFormat("_gridSeparator")) {
                var leftWidth: Number = leftDatagrid.width + event.localX;
                var rightWidth: Number = rightDatagrid.width - event.localX;
                // 最小値未満の時のサイズ調整処理
                // ★をコメントアウトすれば分かるけど、↑で計算したまんまの値をそこに入れると「最小値 - サイズ」分データグリッドのサイズがでかくなる
                if (leftWidth < MINIMAM_DATAGRID_SIZE) {
                    rightWidth = rightWidth - (MINIMAM_DATAGRID_SIZE - leftWidth);     // ★
                    leftWidth = MINIMAM_DATAGRID_SIZE;
                }
                if (rightWidth < MINIMAM_DATAGRID_SIZE) {
                    leftWidth = leftWidth - (MINIMAM_DATAGRID_SIZE - rightWidth);      // ★
                    rightWidth = MINIMAM_DATAGRID_SIZE;
                }
                leftDatagrid.width = leftWidth;
                rightDatagrid.width = rightWidth;
            }
        }
        private function dragCompleteHandler(event: DragEvent): void {
            trace("dragCompleteHandler[", event.currentTarget, "]");
        }
        private function get visibleLeftDatagrid(): Boolean {
            return leftDatagrid.visible;
        }
        private function set visibleLeftDatagrid(value: Boolean): void {
            leftDatagrid.visible = value;
            leftDatagrid.includeInLayout = value;
        }
        private function get visibleGridSeparator(): Boolean {
            return gridSeparator.visible;
        }
        private function set visibleGridSeparator(value: Boolean): void {
            gridSeparator.visible = value;
            gridSeparator.includeInLayout = value;
        }

    }
}