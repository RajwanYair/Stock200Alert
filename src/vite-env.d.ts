/// <reference types="vite/client" />

declare const __APP_VERSION__: string;

// G3: TS 6.0 requires explicit declarations for CSS-only side-effect imports
// @fontsource-variable/inter ships no .d.ts; declare the module to satisfy TS2882.
declare module "@fontsource-variable/inter" {}
