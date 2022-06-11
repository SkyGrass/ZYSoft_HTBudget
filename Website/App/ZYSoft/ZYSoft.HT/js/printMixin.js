var printMixin = {
  created() {
    var start = function () {
      var wsImpl = window.WebSocket || window.MozWebSocket;
      // create a new websocket and connect
      window.ws = new wsImpl("ws://127.0.0.1:8181");

      ws.onmessage = function (evt) {
        //inc.innerHTML += evt.data + "<br/>";
      };

      ws.onopen = function () {
        console.info("打印服务已打开");
      };

      ws.onerror = function (reason) {
        layer.msg("打印服务打开失败!");
      };

      ws.onclose = function (e) {
        layer.msg("打印服务已关闭");
      };
    };
    window.onload = start;
  },
  methods: {
    doSend(content) {
      if (window.ws.readyState == 1) {
        window.ws.send(
          JSON.stringify(Object.assign({}, content, self.printObj))
        );
      } else {
        layer.msg("打印服务未开启,请开启后刷新浏览器重试!", { icon: 5 });
      }
    },
    doSign() {
      layer.confirm(
        "确定要设计打印模板吗?",
        { icon: 3, title: "提示" },
        function (index) {
          self.doSend({ FType: 1 });
          layer.close(index);
        }
      );
    },
    doPreView() {
      layer.confirm(
        "确定要预览吗?",
        { icon: 3, title: "提示" },
        function (index) {
          self.doSend({ FType: 2 });
          layer.close(index);
        }
      );
    },
    doPrint() {
      layer.confirm(
        "确定要打印吗?",
        { icon: 3, title: "提示" },
        function (index) {
          self.doSend({ FType: 3 });
          layer.close(index);
        }
      );
    },
  },
};
