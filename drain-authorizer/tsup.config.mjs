import { defineConfig } from "tsup";

export default defineConfig((options) => {
  return {
    entry: ["src/**/*"],
    format: ["esm"],
    keepNames: true,
    dts: false,
    sourcemap: !options.watch,
    clean: true,
    bundle: true,
    target: "es2022",
    platform: "node",
    treeshake: true,
    external: ["@aws-sdk/client-ssm"],
  };
});
