"use strict";

import { assert, assertFrozen, assertNotFrozen } from "./support/commons";
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

  it("returns unfrozen object", () => {
    assertNotFrozen(result)
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

  it("returns frozen object", () => {
    assertFrozen(result)
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

    assertFrozen(obj.a)
    assertFrozen(obj.a.b)
    assertFrozen(obj.a.b.c)
  })
})