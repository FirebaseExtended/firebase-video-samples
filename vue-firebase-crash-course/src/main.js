import { VueFire, VueFireAuth } from 'vuefire'
import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import { getCurrentUser } from 'vuefire'
import { getFirebase } from './firebase';
import { initializeApp } from 'firebase/app';
import App from './App.vue'
import Home from './pages/Home.vue'
import Auth from './pages/Auth.vue'
import Firestore from './pages/Firestore.vue'
import Protected from './pages/Protected.vue'
import Forbidden from './pages/Forbidden.vue'
import City from './pages/City.vue'
import Mouse from './pages/Mouse.vue'

const routes = [
  { path: '/', component: Home, name: 'Home' },
  { path: '/auth', component: Auth, name: "Auth" },
  { path: '/firestore', component: Firestore, name: "Firestore", meta: { isProtected: true } },
  { path: '/protected', component: Protected, name: "Protected", meta: { isProtected: true } },
  { path: '/city/:id', component: City, name: 'City', meta: { isProtected: true } },
  { path: '/forbidden', component: Forbidden, name: 'Forbidden' },
  { path: '/mouse', component: Mouse, name: 'Mouse' },
]

const router = createRouter({ 
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to, from) => {
  const user = await getCurrentUser()
  to.meta.user = user
  if(to.meta.isProtected && !user) {
    return { name: 'Forbidden' }
  }
})

// const { firebaseApp } = getFirebase();
const firebaseApp = initializeApp();
const app = createApp(App)
  .use(VueFire, {
    firebaseApp,
    modules: [
      VueFireAuth(),
    ],
  })
  .use(router)

app.mount('#app')
