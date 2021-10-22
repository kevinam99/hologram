"use strict";

import Type from "../type";
import Utils from "../utils"

export default class Map {
  static has_key$question(map, key) {
    if (map.data.hasOwnProperty(Type.serializedKey(key))) {
      return Type.boolean(true)
      
    } else {
      return Type.boolean(false)
    }
  }

  static put(map, key, value) {
    let newMap = Utils.clone(map)
    newMap.data[Type.serializedKey(key)] = value

    return Utils.freeze(newMap);
  }
}