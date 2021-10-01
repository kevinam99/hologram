"use strict";

import { assert, assertFreezed } from "./support/commons";
import Utils from "../../assets/js/hologram/utils";

describe("clone()", () => {
  let obj, result;

  beforeEach(() => {
    obj = {a: 1, b: {c: 3, d: 4}}
    result = Utils.clone(obj)
  })

  it("clones object recursively (deep clone)", () => {
    assert.deepStrictEqual(result, obj) 
    assert.notEqual(result, obj)
  })

  it("returns freezed object", () => {
    assertFreezed(result)
  })
})

describe("eval()", () => {
  let result;

  beforeEach(() => {
    result = Utils.eval("{value: 2 + 2}")
  })

  it("evaluates code", () => {
    assert.deepStrictEqual(result, {value: 4})
  })

  it("returns freezed object", () => {
    assertFreezed(result)
  })
})

describe("freeze()", () => {
  it("freezes object and all of its properties recursively (deep freeze)", () => {
    let obj = {
      a: {
        b: {
          c: {
            d: 1
          }
        }
      }
    }

    Utils.freeze(obj)
    assertFreezed(obj)
  })
})

describe("isFalse()", () => {
  it("returns true for boxed false value", () => {
    const arg = {type: "boolean", value: false}
    const result = Utils.isFalse(arg)

    assert.isTrue(result)
  })

  it("returns false for values other than boxed false value", () => {
    const arg = {type: "boolean", value: true}
    const result = Utils.isFalse(arg)
    
    assert.isFalse(result)
  })
})



















describe("isFalsy()", () => {
  it("is false", () => {
    const arg = {type: "boolean", value: false}
    const result = Utils.isFalsy(arg)

    assert.isTrue(result)
  })

  it("is nil", () => {
    const arg = {type: "nil"}
    const result = Utils.isFalsy(arg)
    
    assert.isTrue(result)
  })

  it("is not false nor nil", () => {
    const arg = {type: "integer", value: 0}
    const result = Utils.isFalsy(arg)

    assert.isFalse(result)
  })
})

describe("isNil()", () => {
  it("is nil", () => {
    const arg = {type: "nil"}
    const result = Utils.isNil(arg)

    assert.isTrue(result)
  })

  it("is not nil", () => {
    const arg = {type: "boolean", value: false}
    const result = Utils.isNil(arg)
    
    assert.isFalse(result)
  })
})

describe("isTruthy()", () => {
  it("is false", () => {
    const arg = {type: "boolean", value: false}
    const result = Utils.isTruthy(arg)

    assert.isFalse(result)
  })

  it("is nil", () => {
    const arg = {type: "nil"}
    const result = Utils.isTruthy(arg)
    
    assert.isFalse(result)
  })

  it("is not false nor nil", () => {
    const arg = {type: "integer", value: 0}
    const result = Utils.isTruthy(arg)

    assert.isTrue(result)
  })
})

describe("keywordToMap()", () => {
  it("converts empty keyword list", () => {
    const keyword = {type: "list", data: []}

    const result = Utils.keywordToMap(keyword)
    const expected = {type: "map", data: {}}
    
    assert.deepStrictEqual(result, expected) 
  })

  it("converts non-empty keyword list", () => {
    const keyword = {
      type: "list",
      data: [
        {
          type: "tuple", 
          data: [
            {type: "atom", value: "a"},
            {type: "integer", value: 1}
          ]
        },
        {
          type: "tuple", 
          data: [
            {type: "atom", value: "b"},
            {type: "integer", value: 2}
          ]
        }
      ]
    }

    const result = Utils.keywordToMap(keyword)

    const expected = {
      type: "map", 
      data: {
        "~atom[a]": {type: "integer", value: 1},
        "~atom[b]": {type: "integer", value: 2}
      }
    }
    
    assert.deepStrictEqual(result, expected) 
  })

  it("overwrites same keys", () => {
    const keyword = {
      type: "list",
      data: [
        {
          type: "tuple", 
          data: [
            {type: "atom", value: "a"},
            {type: "integer", value: 1}
          ]
        },
        {
          type: "tuple", 
          data: [
            {type: "atom", value: "b"},
            {type: "integer", value: 2}
          ]
        },
        {
          type: "tuple", 
          data: [
            {type: "atom", value: "a"},
            {type: "integer", value: 9}
          ]
        },
      ]
    }

    const result = Utils.keywordToMap(keyword)

    const expected = {
      type: "map", 
      data: {
        "~atom[a]": {type: "integer", value: 9},
        "~atom[b]": {type: "integer", value: 2}
      }
    }
    
    assert.deepStrictEqual(result, expected) 
  })
})

describe("serialize()", () => {
  it("serializes atom", () => {
    const arg = {type: "atom", value: "test"}
    const result = Utils.serialize(arg)

    assert.equal(result, "~atom[test]")
  })

  it("serializes string", () => {
    const arg = {type: "string", value: "test"}
    const result = Utils.serialize(arg)

    assert.equal(result, "~string[test]")
  })

  it("throws an error for unsupported types", () => {
    const arg = {type: "invalid", value: "test"}
    assert.throw(() => { Utils.serialize(arg) }, "Not implemented, at Utils.serialize()");
  })
})