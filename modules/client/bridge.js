const ModulesBridge = {
  Loaded: {},

  Load(name, path) {
    try {
      const resolved = require.resolve(`../../${path}`);

      delete require.cache[resolved];

      const module = require(resolved);

      this.Loaded[name] = {
        path,
        module,
      };

      console.log(`^2[Modules]^0 Client JS loaded: ${name}`);

      if (module && typeof module.start === "function") {
        module.start();
      }

      return true;
    } catch (error) {
      console.log(`^1[Modules]^0 Client JS error: ${name}`);

      console.error(error);

      return false;
    }
  },

  Stop(name) {
    const loaded = this.Loaded[name];

    if (!loaded) {
      return true;
    }

    try {
      if (loaded.module && typeof loaded.module.stop === "function") {
        loaded.module.stop();
      }
    } catch (error) {
      console.log(`^1[Modules]^0 Client JS stop error: ${name}`);

      console.error(error);
    }

    delete this.Loaded[name];

    return true;
  },

  Reload(name, path) {
    this.Stop(name);

    return this.Load(name, path);
  },
};

on("Furious:Modules:JS:Reload", (name, path) => {
  ModulesBridge.Reload(name, path);
});

on("Furious:Modules:JS:Stop", (name) => {
  ModulesBridge.Stop(name);
});
