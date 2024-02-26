import { ref, onMounted, onUnmounted } from 'vue'

export function useMouse() {
  const x = ref(0)
  const y = ref(0)
  
  onMounted(() => {
    window.addEventListener('mousemove', mouseEvent => {
      x.value = mouseEvent.pageX
      y.value = mouseEvent.pageY
    })
  })
  
  onUnmounted(() => {
    window.removeEventListener('mousemove', mouseEvent => {
      x.value = mouseEvent.pageX
      y.value = mouseEvent.pageY
    })
  })

  return { x, y }
}
