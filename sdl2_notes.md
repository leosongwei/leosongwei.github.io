SDL2笔记
-------

tags: sdl2;

使用surface：

```lisp
(ql:quickload 'sdl2)

(sdl2-ffi.functions:sdl-init sdl2-ffi:+sdl-init-video+)

(defparameter *window*
  (cffi:with-foreign-string (title "hello")
    (sdl2-ffi.functions:sdl-create-window
     title
     sdl2-ffi:+sdl-windowpos-undefined+ sdl2-ffi:+sdl-windowpos-undefined+
     400 200
     sdl2-ffi:+sdl-window-shown+)))

(plus-c:c-let ((rect sdl2-ffi:sdl-rect))
  (setf (rect :x) 0)
  (setf (rect :y) 0)
  (setf (rect :w) 40)
  (setf (rect :h) 20)
  rect)

(defparameter *window-surface* (sdl2-ffi.functions:sdl-get-window-surface *window*))

(defparameter *canvas-surface* (sdl2-ffi.functions:sdl-create-rgb-surface
                                0 400 200
                                32 0 0 0 0))

;; According to the SDL_surface.h: #define SDL_BlitSurface SDL_UpperBlit
(sdl2-ffi.functions::sdl-upper-blit *canvas-surface* (cffi:null-pointer)
                                    *window-surface* (cffi:null-pointer))

(sdl2-ffi.functions:sdl-update-window-surface *window*)
```
