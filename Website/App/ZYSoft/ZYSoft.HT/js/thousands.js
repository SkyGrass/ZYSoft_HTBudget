// el-input格式化自定义指令
/**
 * @name inputFormatter
 * @msg: el-input格式化自定义指令
 * @param {Function} formatter 格式化函数
 * @param {Function} parser 解析函数
 * @param {Function} limit 输入限制函数
 * @param {Boolean} watchInput 是否监听input事件格式化显示
 * @param {Boolean} isNumber 是否为数字类型输入框（小数）
 * @returns 返回自定义指令生命周期函数
 */
var inputFormatter = function(opt){
    var formatter = opt.formatter || function(e){return e;};
    var parser = parser || function(e){return e;};
    var limit = opt.formatter || function(e){return e;};
    var watchInput = opt.watchInput || true;
    var isNumber = opt.isNumber || false

    return function(el, binding, vnode) {
        var watchVal = true
        var input = $(el).find(".el-input__inner")[0]
        // 获取记录光标位置
        var selectionSite
        var getSelectionSite = function(event) {
            var oldVal = event.target.value || ''
            var selectionStart = event.target.selectionStart
            selectionSite = oldVal.length - selectionStart
        }
        // 点击、键盘事件更新光标位置
        el.addEventListener("click", getSelectionSite)
        el.addEventListener("keyup", getSelectionSite)
        //为input绑定值赋值
        var assignment = function(val) {
            vnode.componentInstance.$emit('input', parser(val))
        }
        // 更改显示的值
        var upShow = function(val){
            vnode.context.$nextTick(function() {
                input.value = val
            })
        }
        // 监听绑定值变化
        vnode.componentInstance.$watch('value', function(val){
            if (watchVal) { upShow(formatter(val)) }
        }, { deep: true, immediate: true })
        // 数字格式化
        var toNumber = function(val) {
            val = val.toString().replace(/[^\d^\.^\-]+/g, "") // 第二步：把不是数字，不是小数点、-的过滤掉
                .replace(/^0+(\d)/, "$1") // 第三步：第一位0开头，0后面为数字，则过滤掉，取后面的数字
                .replace(/^\./, "0.") // 第四步：如果输入的第一位为小数点，则替换成 0. 实现自动补全
                .replace(".", "$#$").replace(/\./g, "").replace("$#$", ".") // 只保留第一个".", 清除多余的"."
            // .match(/^\d*(\.?\d{0,9})/g)[0] || ""; // 第五步：最终匹配得到结果 以数字开头，只有一个小数点，而且小数点后面只能有1到9位小数
            return val
        }
        // 处理最后一位非法字符
        var handlerIllegalStr = function(str){
            while (!(/^[0-9]+.?[0-9]*/.test(str.charAt(str.length - 1))) && str) {
                str = str.substr(0, str.length - 1)
            }
            return str || ''
        }
        // 监听input事件，可添加操作
        el.addEventListener("input", function(event) {
            var selectionStart = input.selectionStart
            var val = event.target.value
            if (binding.modifiers.number || isNumber) {
                val = toNumber(val)
            }
            var inp = limit(val)
            event.target.value = inp
            if (binding.modifiers.watchInput || watchInput) {
                assignment(inp)
                upShow(formatter(parser(val)))
            }
            setTimeout(function(){
                if (selectionSite && input.value.length != selectionStart) {
                    input.selectionStart = input.selectionEnd = input.value.length - selectionSite
                }
            }, 0)
        })
        if (input) {
            input.addEventListener("blur", function(event){
                watchVal = true
                var val = event.target.value;
                if (binding.modifiers.number || isNumber) {
                    val = handlerIllegalStr(val)
                }
                assignment(val)
            })
            input.addEventListener("focus", function(event){
                watchVal = false
            })
        }
    }
}

Vue.directive('thousands', {
    inserted: inputFormatter({
        // 格式化函数
        formatter(num) { 
            num = num.toString()
            var num1 = num.split(".")[0], num2 = num.split(".")[1];
            var c = num1.toString().replace(/(\d)(?=(?:\d{3})+$)/g, '$1,');
            return num.toString().indexOf(".") !== -1 ? c + "." + num2 : c + '.00';
        },
        // 解析函数
        parser(val) {
            val = val.toString().replace(/,/g, "")
            return val
        },
        isNumber: true
    })
});