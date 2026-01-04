import { defineConfig, type PluginOption } from "vite";
import preact from "@preact/preset-vite";
import path from "path";
import { visualizer } from "rollup-plugin-visualizer";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [preact() as unknown as PluginOption, visualizer() as unknown as PluginOption],
  base: "./",
  build: {
    outDir: "../dist",
    emptyOutDir: true,
    minify: "terser",
    sourcemap: false,
    terserOptions: {
      compress: {
        drop_console: true,
        drop_debugger: true,
        pure_funcs: [
          "console.log",
          "console.info",
          "console.debug",
          "console.trace",
        ],
        passes: 2,
        ecma: 2020,
      },
      format: {
        comments: false,
        ecma: 2020,
      },
      mangle: {
        properties: {
          regex: /^_/,
        },
      },
    },
    rollupOptions: {
      output: {
        entryFileNames: "assets/[name].[hash].js",
        chunkFileNames: "assets/[name].[hash].js",
        assetFileNames: "assets/[name].[hash].[ext]",
        manualChunks(id: string) {
          if (id.includes("node_modules")) {
            if (id.includes("svelte")) {
              return "svelte";
            }
            return "vendor";
          }
        },
      },
    },
    target: ["es2020", "edge88", "firefox78", "chrome87", "safari14"],
    cssCodeSplit: true,
    assetsInlineLimit: 4096,
    chunkSizeWarningLimit: 1000,
    reportCompressedSize: true,
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
      "~": path.resolve(__dirname, "./"),
      $lib: path.resolve("./src/lib"),
    },
  },
});
