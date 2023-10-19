"use strict";

import Bitstring from "./bitstring.mjs";
import HologramError from "./error.mjs";
import Interpreter from "./interpreter.mjs";
import Renderer from "./renderer.mjs";
import Type from "./type.mjs";

export default class Hologram {
  static deps = {
    HologramError: HologramError,
    Interpreter: Interpreter,
    Type: Type,
  };

  static clientsData = null;
  static isInitiated = false;
  static pageModule = null;
  static pageParams = null;

  // TODO: implement
  static init() {}

  static mountPage() {
    window.__hologramPageReachableFunctionDefs__(Hologram.deps);

    const mountData = window.__hologramPageMountData__(Hologram.deps);
    Hologram.clientsData = mountData.clientsData;
    Hologram.pageModule = mountData.pageModule;
    Hologram.pageParams = mountData.pageParams;

    Renderer.renderPage(
      mountData.pageModule,
      mountData.pageParam,
      mountData.clientsData,
    );
  }

  static onReady(callback) {
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

  static run() {
    Hologram.onReady(() => {
      if (!Hologram.isInitiated) {
        Hologram.init();
      }

      try {
        Hologram.mountPage();
      } catch (error) {
        if (error instanceof HologramError) {
          console.dir(error.struct);

          const type = Interpreter.fetchErrorType(error);

          // TODO: use transpiled Elixir code
          const message = Bitstring.toText(
            error.struct.data["atom(message)"][1],
          );

          console.error(`${type}: ${message}`);
        }
        throw error;
      }
    });
  }
}
