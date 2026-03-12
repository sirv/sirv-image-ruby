# frozen_string_literal: true

require_relative "../lib/sirv_client"

# ---- Create a client ---------------------------------------------------------

sirv = Sirv::SirvClient.new(domain: "demo.sirv.com", defaults: { q: 80 })

# ---- Build URLs --------------------------------------------------------------

url = sirv.url("/photo.jpg", w: 400, h: 300, format: "webp")
puts "Basic URL:"
puts url
puts

# ---- Nested params (dot-notation) -------------------------------------------

url = sirv.url("/portrait.jpg",
               w: 200, h: 200,
               crop: { type: "face", pad: { width: 30, height: 30 } })
puts "Nested params:"
puts url
puts

# ---- Responsive srcset with explicit widths ----------------------------------

srcset = sirv.src_set("/photo.jpg", { format: "webp" }, widths: [320, 640, 960, 1280])
puts "srcset (explicit widths):"
puts srcset
puts

# ---- Responsive srcset with auto-range --------------------------------------

srcset = sirv.src_set("/photo.jpg", { format: "webp" },
                      min_width: 200, max_width: 2000, tolerance: 0.15)
puts "srcset (auto-range):"
puts srcset
puts

# ---- Responsive srcset with device pixel ratios ------------------------------

srcset = sirv.src_set("/hero.jpg", { w: 600, h: 400 },
                      device_pixel_ratios: [1, 2, 3])
puts "srcset (DPR):"
puts srcset
puts

# ---- Image tag ---------------------------------------------------------------

html = sirv.image("/tomatoes.jpg",
                  alt: "Fresh tomatoes",
                  transform: { w: 300, format: "webp" },
                  viewer: { autostart: "visible" })
puts "Image tag:"
puts html
puts

# ---- Zoom viewer -------------------------------------------------------------

html = sirv.zoom("/product.jpg",
                 viewer: { mode: "deep", wheel: false })
puts "Zoom viewer:"
puts html
puts

# ---- Spin viewer -------------------------------------------------------------

html = sirv.spin("/product.spin",
                 viewer: { autostart: "visible", autospin: "lazy" })
puts "Spin viewer:"
puts html
puts

# ---- Video -------------------------------------------------------------------

html = sirv.video("/clip.mp4")
puts "Video:"
puts html
puts

# ---- 3D model ----------------------------------------------------------------

html = sirv.model("/shoe.glb")
puts "3D model:"
puts html
puts

# ---- Gallery -----------------------------------------------------------------

html = sirv.gallery(
  [
    { src: "/product.spin" },
    { src: "/front.jpg", type: "zoom", viewer: { mode: "deep" } },
    { src: "/side.jpg", type: "zoom" },
    { src: "/detail.mp4" }
  ],
  viewer: { arrows: true, thumbnails: "bottom" },
  class_name: "product-gallery"
)
puts "Gallery:"
puts html
puts

# ---- Script tag --------------------------------------------------------------

html = sirv.script_tag(modules: ["spin", "zoom"])
puts "Script tag:"
puts html
puts

html = sirv.script_tag
puts "Script tag (all modules):"
puts html
