function get_categories() {
    var url = api_url + '?auth=' + auth_key + '&method=category_list'

    var xhr = new XMLHttpRequest()
    xhr.open('GET', url, true)
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            var results = JSON.parse(xhr.responseText)

            filtersPage.getCategoriesFinished(results)
        }
    }

    xhr.send()
}

function get_wallpapers(page) {
    var url = ""

    if (filtersPage.featuredSelected) {
        url = api_url + '?auth=' + auth_key + '&method=featured&sort=' + filtersPage.sorting + '&page=' + page + '&info_level=3';
    } else if (filtersPage.allSelected) {
        url = api_url + '?auth=' + auth_key + '&method=' + filtersPage.sorting_method + '&page=' + page + '&info_level=3';
    } else {
        url = api_url + '?auth=' + auth_key + '&method=category&id=' + filtersPage.selectedCategory + '&sort=' + filtersPage.sorting + '&page=' + page + '&info_level=3';
    }

    if (wallpapersPage.collection_id) {
        url = api_url + '?auth=' + auth_key + '&method=collection&id=' + wallpapersPage.collection_id + '&sort=' + filtersPage.sorting + '&page=' + page + '&info_level=3';
    }

    if (wallpapersPage.group_id) {
        url = api_url + '?auth=' + auth_key + '&method=group&id=' + wallpapersPage.group_id + '&sort=' + filtersPage.sorting + '&page=' + page + '&info_level=3';
    }

    var resVal = filtersPage.res_vals[filtersPage.res]
    if (resVal.width != 0 && resVal.height != 0) {
        url = url + '&width=' + resVal.width + '&height=' + resVal.height;
    }

    var xhr = new XMLHttpRequest()
    xhr.open('GET', url, true)
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            var results = JSON.parse(xhr.responseText)

            wallpapersPage.getWallpapersFinished(results)
        }
    }

    xhr.send();
}

function search_wallpapers(page, term) {
    var url = api_url + '?auth=' + auth_key + '&method=search&term=' + term + '&page=' + page + '&info_level=3';

    var xhr = new XMLHttpRequest()
    xhr.open('GET', url, true)
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            var results = JSON.parse(xhr.responseText)

            wallpapersPage.getWallpapersFinished(results);
        }
    }

    xhr.send();
}
