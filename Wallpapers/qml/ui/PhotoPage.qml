import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Content 1.1
import Ubuntu.DownloadManager 1.2

import "../components"
import "../js/scripts.js" as Scripts

Page {
    id: photoPage

    // Photo Actions
    property list<Action> photoActions: [
        Action {
            id: makeWallpaperAction
            text: i18n.tr("Make Wallpaper")
            iconName: "tick"
            onTriggered: {
                confirmExport()
            }
        },
        Action {
            id: downloadAction
            text: i18n.tr("Download")
            iconName: "document-save-as"
            onTriggered: {
                var singleDownload = downloadComponent.createObject(mainView)
                singleDownload.contentType = ContentType.Pictures
                singleDownload.download(photoDetails.url_image)
            }
        },
        Action {
            id: goToCollectionAction
            enabled: photoDetails.collection_id !== 0
            text: i18n.tr("Go to Collection")
            onTriggered: {
                wallpapersPage.collection_id = photoDetails.collection_id
                wallpapersPage.collection_name = photoDetails.collection

                wallpapersPage.group_id = 0
                wallpapersPage.group_name = ""

                wallpapersPage.currentPage = 1
                wallpapersPage.getWallpapers()

                pageStack.pop()
            }
        },
        Action {
            id: goToGroupAction
            enabled: photoDetails.group_id !== 0
            text: i18n.tr("Go to Group")
            onTriggered: {
                wallpapersPage.collection_id = 0
                wallpapersPage.collection_name = ""

                wallpapersPage.group_id = photoDetails.group_id
                wallpapersPage.group_name = photoDetails.group

                wallpapersPage.currentPage = 1
                wallpapersPage.getWallpapers()

                pageStack.pop()
            }
        }
    ]

    header: PageHeader {
        title: i18n.tr("Photo")
        trailingActionBar {
            numberOfSlots: 2
            actions: is_transfer ? [makeWallpaperAction, goToCollectionAction, goToGroupAction] : [downloadAction, goToCollectionAction, goToGroupAction]
        }
    }

    property var photoDetails

    function confirmExport() {
        var photo_urls = [photoDetails.url_image]

        var results = photo_urls.map(function(photoUrl) {
            return photoSelectorResultComponent.createObject(mainView, {"url": photoUrl})
        })

        mainView.transfer.items = results
        mainView.transfer.state = ContentTransfer.Charged
        mainView.transfer = null

        mainView.is_transfer = false
    }

    function cancelExport() {
        if (mainView.transfer) {
             mainView.transfer.state = ContentTransfer.Aborted
             mainView.transfer = null
        }

        mainView.is_transfer = false
    }

    Component.onCompleted: {

    }

    BouncingProgressBar {
        z: 10
        anchors.top: photoPage.header.bottom
        visible: photo.status == Image.Loading
    }

    Flickable {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: photoPage.header.bottom
        }

        Column {
            width: parent.width
            spacing: 5

            Image {
                id: photo
                visible: photo.status == Image.Ready
                width: parent.width
                height: photoDetails.height/(photoDetails.width/width)
                sourceSize.width: width
                sourceSize.height: height
                anchors.horizontalCenter: parent.horizontalCenter
                clip: true
                source: photoDetails.url_image
                smooth: true
                fillMode: Image.PreserveAspectFit
            }
        }
}
}
