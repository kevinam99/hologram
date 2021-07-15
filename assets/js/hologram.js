import "core-js/stable";
import "regenerator-runtime/runtime"; 

// see: https://www.blazemeter.com/blog/the-correct-way-to-import-lodash-libraries-a-benchmark
import cloneDeep from "lodash/cloneDeep";

import {attributesModule, eventListenersModule, h, init, toVNode} from "snabbdom";
const patch = init([eventListenersModule, attributesModule]);

import Client from "./hologram/client"
import DOM from "./hologram/dom"
import Runtime from "./hologram/runtime"

export default class Hologram {
  // TODO: refactor & test functions below

  static evaluate(value) {
    switch (value.type) {
      case "integer":
        return `${value.value}`
    }
  }

  static get_module(name) {
    return eval(name.replace(/\./g, ""))
  }

  static isPatternMatched(left, right) {
    let lType = left.type;
    let rType = right.type;

    if (lType != 'placeholder') {
      if (lType != rType) {
        return false;
      }

      if (lType == 'atom' && left.value != right.value) {
        return false;
      }
    }

    return true;
  }

  static js(js) {
    eval(js.value)
  }

  static objectKey(key) {
    switch (key.type) {
      case 'atom':
        return `~atom[${key.value}]`

      case 'string':
        return `~string[${key.value}]`
        
      default:
        throw 'Not implemented, at HologramPage.objectKey()'
    }
  }

  static onReady(document, callback) {
    if (
      document.readyState === "interactive" ||
      document.readyState === "complete"
    ) {
      callback();
    } else {
      document.addEventListener("DOMContentLoaded", function listener() {
        document.removeEventListener("DOMContentLoaded", listener);
        callback();
      });
    }
  }

  static patternMatchFunctionArgs(params, args) {
    if (args.length != params.length) {
      return false;
    }

    for (let i = 0; i < params.length; ++ i) {
      if (!Hologram.isPatternMatched(params[i], args[i])) {
        return false;
      }
    }

    return true;
  }

  static render(prev_vnode, context, runtime) {
    let template = context.pageModule.template()
    context.scopeModule = context.pageModule
    let vnode = DOM.buildVNode(template, runtime.state, context, runtime)[0]
    patch(prev_vnode, vnode)

    return vnode
  }

  static run(window, pageModule, state) {
    Hologram.onReady(window.document, () => {
      const client = new Client()
      const runtime = new Runtime(state)

      let container = window.document.body
      window.prev_vnode = toVNode(container)
      let context = {scopeModule: pageModule, pageModule: pageModule}
      window.prev_vnode = Hologram.render(window.prev_vnode, context, runtime)
    })
  }
}

class Kernel {
  static $add(left, right) {
    let type = left.type == "integer" && right.type == "integer" ? "integer" : "float"
    return { type: type, value: left.value + right.value }
  }

  static $dot(left, right) {
    return cloneDeep(left.data[Hologram.objectKey(right)])
  }
}

class Map {
  static put(map, key, value) {
    let mapClone = cloneDeep(map)
    mapClone.data[Hologram.objectKey(key)] = value
    return mapClone;
  }
}

window.Hologram = Hologram
window.Kernel = Kernel
window.Map = Map