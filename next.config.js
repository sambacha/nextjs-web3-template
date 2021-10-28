const withPWA = require('next-pwa')
const runtimeCaching = require('next-pwa/cache')

const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
})

// Paths that mustn't have rewrite applied to them, to avoid the whole app to behave inconsistently
// All items (folders, files) under /public directory should be added there, to avoid redirection when an asset isn't found
// Will disable url rewrite for those items (should contain all supported languages and all public base paths)
const noRedirectBlacklistedPaths = ['_next', 'api']; 
const publicBasePaths = ['robots', 'static', 'favicon.ico']; 
const noRedirectBasePaths = [ ...publicBasePaths, ...noRedirectBlacklistedPaths]; // ...sourceLocale

// @ts-check
/**
 * @type {import('next').NextConfig}
 */
const nextConfig = {
  productionBrowserSourceMaps: false,
  poweredByHeader: false,
  reactStrictMode: true,
  experimental: { esmExternals: true },
  pwa: {
    dest: 'public',
    runtimeCaching,
    disable: process.env.NODE_ENV === 'development',
  },
  images: {
    minimumCacheTTL: 1209600,
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
    domains: ['raw.githubusercontent.com'],
  }
}

// Make sure adding Sentry options is the last code to run before exporting, to
// ensure that your source maps include changes from all other Webpack plugins
module.exports = withPWA(withBundleAnalyzer(nextConfig))

// Don't delete this console log, useful to see the config in Vercel deployments
console.log('next.config.js', JSON.stringify(module.exports, null, 2))