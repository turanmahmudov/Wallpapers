import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

import "../js/scripts.js" as Scripts

Page {
    id: filtersPage

    header: PageHeader {
        title: i18n.tr("Wallpapers")
        leadingActionBar.actions: [
            Action {
                id: closePageAction
                text: i18n.tr("Close")
                iconName: "close"
                onTriggered: {
                    // Revert
                    allSelected = savedAllSelected
                    featuredSelected = savedFeaturedSelected
                    selectedCategory = savedSelectedCategory

                    if (categoriesModel.count != 0) {
                        getCategories(true)
                    }

                    pageStack.pop();
                }
            }
        ]

        trailingActionBar {
            numberOfSlots: 1
            actions: [
                Action {
                    id: saveAction
                    text: i18n.tr("Save")
                    iconName: "tick"
                    onTriggered: {
                        wallpapersPage.collection_id = 0
                        wallpapersPage.collection_name = ""

                        wallpapersPage.group_id = 0
                        wallpapersPage.group_name = ""

                        wallpapersPage.currentPage = 1
                        wallpapersPage.getWallpapers()

                        // Update
                        savedAllSelected = allSelected
                        savedFeaturedSelected = featuredSelected
                        savedSelectedCategory = selectedCategory

                        pageStack.pop()
                    }
                }
            ]
        }
    }

    // Sorting Model & Vals & Methods
    property var sortingModel: [
        i18n.tr("Latest"),
        i18n.tr("Ratings"),
        i18n.tr("Views"),
        i18n.tr("Favorites")
    ]
    property var sorting_vals: ["newest","rating","views","favorites"]
    property var sorting_methods: ["newest","highest_rated","by_views","by_favorites"]

    // Resolution Model & Vals
    property var resModel: [
        i18n.tr("All"),
        i18n.tr("HD Wallpapers"),
        i18n.tr("UltraHD 4k Wallpapers"),
        i18n.tr("Retina 5k Wallpapers")
    ]
    property var res_vals: [{"width":0, "height":0}, {"width":1920, "height":1080}, {"width":3840, "height":2160}, {"width":5120, "height":2880}]

    property var categoryData

    // Update these
    property bool featuredSelected: false
    property bool allSelected: true
    property int selectedCategory: 0

    property string sorting: "newest"
    property string sorting_method: "newest"

    property int res: 0

    // Revert back
    property bool savedFeaturedSelected: false
    property bool savedAllSelected: true
    property int savedSelectedCategory: 0

    signal refreshList()

    property bool clear_models: false

    function getCategoriesFinished(data)
    {
        var checkboxes_saved_data = {"all":savedAllSelected, "featured":savedFeaturedSelected, "category":savedSelectedCategory}

        categoryData = data
        if (data.success) {
            worker.sendMessage({'feed': 'filtersPage', 'obj': data.categories, 'model': categoriesModel, 'checkboxesSaved': checkboxes_saved_data, 'clear_model': clear_models})
        }
    }

    function getCategories(use_old)
    {
        categoriesModel.clear()
        clear_models = true
        if (use_old === true) {
            getCategoriesFinished(categoryData)
        } else {
            Scripts.get_categories();
        }
    }

    WorkerScript {
        id: worker
        source: "../js/Worker.js"
        onMessage: {

        }
    }

    Component.onCompleted: {
        getCategories(false)
    }

    ListModel {
        id: categoriesModel
    }

    ListView {
        id: categoriesList
        anchors {
            left: parent.left
            right: parent.right
            bottom: bottomFilter.top
            top: filtersPage.header.bottom
        }
        clip: true
        model: categoriesModel
        delegate: ListItem {
            id: categoriesDelegate
            height: layout2.height
            divider.visible: index == 1 ? true : false
            onClicked: {
                categoryChecked.checked = !categoryChecked.checked
                categoryChecked.changeVal()
            }

            SlotsLayout {
                id: layout2
                anchors.centerIn: parent

                padding.leading: 0
                padding.trailing: 0
                padding.top: units.gu(1)
                padding.bottom: units.gu(1)

                mainSlot: Row {
                    id: label2
                    spacing: units.gu(1)
                    width: parent.width

                    Text {
                        text: all ? i18n.tr("All") : (featured ? i18n.tr("Featured") : phObj.name)
                    }
                }

                CheckBox {
                    id: categoryChecked
                    anchors.verticalCenter: parent.verticalCenter
                    SlotsLayout.position: SlotsLayout.Leading
                    SlotsLayout.overrideVerticalPositioning: true

                    checked: all || featured ? cchecked : phObj.cchecked

                    onClicked: {
                        categoryChecked.changeVal()
                    }

                    function changeVal() {
                        if (index == 0) {
                            allSelected = categoryChecked.checked
                            featuredSelected = !categoryChecked.checked

                            selectedCategory = 0
                        } else if (index == 1) {
                            allSelected = !categoryChecked.checked
                            featuredSelected = categoryChecked.checked

                            selectedCategory = 0
                        } else {
                            if (categoryChecked.checked) {
                                featuredSelected = false
                                allSelected = false

                                selectedCategory = phObj.id
                            } else {
                                featuredSelected = false
                                allSelected = true

                                selectedCategory = 0
                            }
                        }

                        refreshList()
                    }

                    Connections {
                        target: filtersPage
                        onRefreshList: {
                            if (index == 0) {
                                categoryChecked.checked = allSelected
                            } else if (index == 1) {
                                categoryChecked.checked = featuredSelected
                            } else {
                                if (selectedCategory == phObj.id) {
                                    categoryChecked.checked = true
                                } else {
                                    categoryChecked.checked = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: bottomFilter
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: units.gu(6)

        Rectangle {
            width: parent.width
            height: units.gu(0.1)
            color: "#cdcdcd"
        }

        Row {
            width: parent.width
            height: parent.height - units.gu(0.1)
            anchors.top: parent.top
            anchors.topMargin: units.gu(0.1)

            Rectangle {
                id: sortList
                width: parent.width/2
                height: parent.height

                Column {
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(1)
                        right: parent.right
                        rightMargin: units.gu(1)
                    }
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: i18n.tr("Sort by")
                        font.weight: Font.DemiBold
                    }

                    Row {
                        spacing: units.gu(0.5)
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: sortingModel[sorting_vals.indexOf(sorting)]
                            width: sortList.width
                            wrapMode: Text.WrapAnywhere
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        PopupUtils.open(sortingDialog)
                    }
                }
            }

            Rectangle {
                id: resList
                width: parent.width/2
                height: parent.height

                Column {
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(1)
                        right: parent.right
                        rightMargin: units.gu(1)
                    }
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: i18n.tr("Resolution")
                        font.weight: Font.DemiBold
                    }

                    Row {
                        spacing: units.gu(0.5)
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: resModel[res]
                            width: resList.width
                            wrapMode: Text.WrapAnywhere
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        PopupUtils.open(resDialog)
                    }
                }
            }
        }
    }

    Component {
        id: sortingDialog
        Dialog {
            id: dialog

            title: i18n.tr("Sort by")

            OptionSelector {
                id: optionSelector
                expanded: true
                selectedIndex: sorting_vals.indexOf(sorting)
                model: sortingModel
                onDelegateClicked: {
                    sorting = sorting_vals[index]
                    sorting_method = sorting_methods[index]

                    wallpapersPage.currentPage = 1
                    wallpapersPage.getWallpapers()

                    PopupUtils.close(dialog);
                }
            }
        }
    }

    Component {
        id: resDialog
        Dialog {
            id: dialog

            title: i18n.tr("Resolution")

            OptionSelector {
                id: optionSelector
                expanded: true
                selectedIndex: res
                model: resModel
                onDelegateClicked: {
                    res = index

                    wallpapersPage.currentPage = 1
                    wallpapersPage.getWallpapers()

                    PopupUtils.close(dialog);
                }
            }
        }
    }
}
