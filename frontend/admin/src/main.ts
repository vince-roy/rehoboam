import 'isomorphic-unfetch';
import "@fontsource/inter/variable.css"
import "tailwindcss/tailwind.css"
import "./main.css"
import '@fortawesome/fontawesome-svg-core/styles.css'
import { config } from '@fortawesome/fontawesome-svg-core'
import { createApp as createClientOnlyApp, createSSRApp } from 'vue'
import {
  createMemoryHistory,
  createRouter,
  createWebHistory
} from 'vue-router'
import { parse, stringify } from 'qs'
import App from './App'
import routes from './routes'
import useUrql from './useUrql';

if (import.meta.env.PROD) {
  config.autoAddCss = false
}

// SSR requires a fresh app instance per request, therefore we export a function
// that creates a fresh app instance. If using Vuex, we'd also be creating a
// fresh store here.
export function createApp(args : {headers?: string[]} = {}) {

  const {
    client,
    ssr
  } = useUrql(args)

  const router = createRouter({
    history: import.meta.env.SSR ? createMemoryHistory() : createWebHistory(),
    // @ts-ignore
    parseQuery: parse,
    routes, 
    scrollBehavior(to, from, savedPosition) {
      if (
        (from.name === to.name && to.query?.aside || from.query?.aside) &&
        document.getElementById('book')
      ) {
        return {
          behavior: 'smooth',
          top: (document.getElementById('book')?.getBoundingClientRect().top || 0) + window.pageYOffset
        }
      }
      // always scroll to top
      return { top: 0 }
    },
    stringifyQuery: stringify
  })

  const app = import.meta.env.SSR || (window as any).__URQL_DATA__
    ? createSSRApp(App) 
    : createClientOnlyApp(App)
  app.provide("$urql", client)
  app.use(router)

  return { app, router, ssr }
}