import QtQuick 2.4
import Ubuntu.Components 1.3

import "../components"
import "../js/scripts.js" as Scripts

Page {
    id: wallpapersPage

    header: state == "default" ? defaultHeader : searchPageHeader
    state: "default"

    PageHeader {
        id: defaultHeader
        visible: wallpapersPage.state == "default"
        title: collection_id ? collection_name : (group_id ? group_name : i18n.tr("Wallpapers"))
        leadingActionBar {
            actions: navActions
        }
        trailingActionBar {
            numberOfSlots: 2
            actions: [searchAction, filterAction]
        }
    }

    PageHeader {
        id: searchPageHeader
        visible: wallpapersPage.state == "search"
        title: i18n.tr("Search")
        leadingActionBar {
            actions: [
                Action {
                    id: closePageAction
                    text: i18n.tr("Close")
                    iconName: "back"
                    onTriggered: {
                        wallpapersPage.state = "default"
                        currentPage = 1
                        getWallpapers()
                    }
                }

            ]
        }
        trailingActionBar {
            numberOfSlots: 1
            actions: [filterAction]
        }

        contents: Rectangle {
            color: "#fff"
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            TextField {
                id: searchField
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                primaryItem: Icon {
                    anchors.leftMargin: units.gu(0.2)
                    height: parent.height*0.5
                    width: height
                    name: "find"
                }
                hasClearButton: true
                inputMethodHints: Qt.ImhNoPredictiveText
                onVisibleChanged: {
                    if (visible) {
                        forceActiveFocus()
                    }
                }
                onAccepted: {
                    collection_id = 0
                    collection_name = ""

                    group_id = 0
                    group_name = ""

                    search_term = searchField.text
                    currentPage = 1
                    getWallpapers()
                }
            }
        }
    }

    property int currentPage: 1
    property bool next_coming: true
    property bool more_available: true

    property bool clear_models: false

    property bool list_loading: false

    property string search_term: ""

    property int collection_id: 0
    property string collection_name: ""

    property int group_id: 0
    property string group_name: ""

    function getWallpapersFinished(data)
    {
        if (data.success) {
            if (data.wallpapers.length == 0) {
                more_available = false
            } else {
                more_available = true
            }

            next_coming = true

            worker.sendMessage({'feed': 'wallpapersPage', 'obj': data.wallpapers, 'model': wallpapersModel, 'clear_model': clear_models})

            next_coming = false

            list_loading = false
        }
    }

    function getWallpapers()
    {
        list_loading = true
        clear_models = false
        if (currentPage == 0 || currentPage == 1) {
            wallpapersModel.clear()
            clear_models = true
            currentPage = 1
        }
        if (wallpapersPage.state == "search") {
            Scripts.search_wallpapers(currentPage, search_term)
        } else {
            Scripts.get_wallpapers(currentPage)
        }
    }

    WorkerScript {
        id: worker
        source: "../js/Worker.js"
        onMessage: {

        }
    }

    Component.onCompleted: {
        getWallpapers()
    }

    BouncingProgressBar {
        z: 10
        anchors.top: wallpapersPage.header.bottom
        visible: wallpapersModel.count == 0 || list_loading
    }

    ListModel {
        id: wallpapersModel
    }

    GridView {
        id: wallpapersView
        visible: wallpapersModel.count > 0
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: wallpapersPage.header.bottom
        }
        cellWidth: isLandscape ? (parent.width/3) : (parent.width/2)
        cellHeight: cellWidth*3/4
        clip: true

        onMovementEnded: {
            if (atYEnd && !next_coming && more_available) {
                currentPage = currentPage + 1
                getWallpapers()
            }
        }

        model: wallpapersModel
        delegate: Item {
            width: wallpapersView.cellWidth
            height: wallpapersView.cellHeight
            clip: true

            Column {
                anchors.fill: parent
                anchors.margins: 2
                Image {
                    width: parent.width
                    height: parent.height
                    sourceSize.width: width
                    sourceSize.height: height
                    clip: true
                    source: url_thumb
                    fillMode: Image.PreserveAspectCrop
                    layer.enabled: status != Image.Ready
                    layer.effect: Rectangle {
                        anchors.fill: parent
                        color: "#efefef"
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("PhotoPage.qml"), {"photoDetails": wallpapersModel.get(index)})
                }
            }
        }
        PullToRefresh {
            id: pullToRefresh
            refreshing: list_loading && wallpapersModel.count == 0
            onRefresh: {
                currentPage = 1
                getWallpapers()
            }
        }
    }
}
