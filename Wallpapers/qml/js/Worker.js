WorkerScript.onMessage = function(msg) {
    // Get params from msg
    var feed = msg.feed;
    var obj = msg.obj;
    var model = msg.model;

    if (msg.clear_model) {
        model.clear();
    }

    if (feed == "filtersPage") {
        var checkboxesSaved = msg.checkboxesSaved;

        model.append({"featured":false, "all":true, "category":false, "cchecked":checkboxesSaved.all})
        model.append({"featured":true, "all":false, "category":false, "cchecked":checkboxesSaved.featured})

        for (var i = 0; i < obj.length; i++) {
            if (checkboxesSaved.category == obj[i].id) {
                obj[i].cchecked = true
            } else {
                obj[i].cchecked = false
            }

            model.append({"featured":false, "all":false, "category":true, "phObj": obj[i]})

            model.sync();

            WorkerScript.sendMessage({})
        }
    } else {
        for (var i = 0; i < obj.length; i++) {
            model.append(obj[i]);

            model.sync();
        }
    }
}
