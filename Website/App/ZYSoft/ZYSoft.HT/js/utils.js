var utils = {
  obj2Url: function (obj) {
    var url = "";
    for (var key in obj) {
      var value = obj[key];
      url += `&${key}=${value}`;
    }
    return url.substring(1);
  },

  url2Obj: function (url) {
    var obj = {};
    if (url == "") return obj;
    if (url[0] == "?") url = url.substring(1);
    url.split("&").forEach(function (ele) {
      var tmp = ele.split("=");
      obj[tmp[0]] = tmp[1];
    });
    return obj;
  },
  format: function (num) {
    var reg = /\d{1,3}(?=(\d{3})+$)/g;
    return (num + ' ').replace(reg, '$&,')
  },
  addThousandSplit: function (num) {
    var flag = false;
    num = num + '';
    var firstStr = num.slice(0, 1);
    if (firstStr === '+' || firstStr === '-') {
      num = num.slice(1);
      flag = true;
    }
    var integer = num.split('.')[0];
    var surplus = num.split('.')[1];
    var arr = integer.split('');
    var val = arr.reduceRight(function (acc, cur, index) {
      if ((arr.length - 1 - index) % 3 === 2 && index !== 0) {
        cur = ',' + cur;
      }
      return cur + acc;
    }, '');
    if (flag === true) {
      flag = false;
      return surplus ? firstStr + val + '.' + surplus : firstStr + val;
    } else {
      return surplus ? val + '.' + surplus : (val + '.00');
    }
  },
  DelThousandSplit(val) {
    var value = val + '';
    if (value.indexOf('.') !== -1) {
      var intPart = value.slice(0, value.indexOf('.'));
      var floatPart = value.slice(value.indexOf('.') + 1);
      var formatIntPart = intPart.split(',').join('');
      var result = formatIntPart + '.' + floatPart;
      return result;
    } else {
      return value.split(',').join('');
    }
  }
}
