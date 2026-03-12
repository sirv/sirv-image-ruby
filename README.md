# Sirv Image Transformation for Ruby

A fluent Ruby builder for constructing [Sirv](https://sirv.com) image transformation URLs. Chain methods to apply resizing, cropping, color adjustments, effects, text overlays, watermarks, and more — then call `to_url` to get the final URL.

## Installation

Add to your Gemfile:

```ruby
gem "sirv_image", path: "/path/to/sirv_image"
```

Or install from the gemspec:

```sh
gem build sirv_image.gemspec
gem install sirv_image-1.0.0.gem
```

Then require it:

```ruby
require "sirv_image"
```

## Quick Start

```ruby
url = Sirv::SirvImage.new("https://demo.sirv.com/photo.jpg")
  .resize(width: 400, height: 300)
  .format("webp")
  .quality(80)
  .to_url
# => "https://demo.sirv.com/photo.jpg?w=400&h=300&format=webp&q=80"
```

## Constructor

```ruby
# Single argument — full URL
img = Sirv::SirvImage.new("https://demo.sirv.com/photo.jpg")

# Two arguments — base URL + path
img = Sirv::SirvImage.new("https://demo.sirv.com", "/photo.jpg")
```

## API Reference

All transformation methods return `self`, enabling method chaining. Call `to_url` or `to_s` to produce the final URL string.

### Resize

| Method | Parameters | URL Params |
|---|---|---|
| `resize` | `width:`, `height:`, `option:` | `w`, `h`, `scale.option` |
| `width` | `w` | `w` |
| `height` | `h` | `h` |
| `scale_by_longest` | `s` | `s` |
| `thumbnail` | `size` | `thumbnail` |

```ruby
Sirv::SirvImage.new(url).resize(width: 400, height: 300, option: "fit")
Sirv::SirvImage.new(url).width(400)
Sirv::SirvImage.new(url).thumbnail(150)
```

### Crop

| Method | Parameters | URL Params |
|---|---|---|
| `crop` | `width:`, `height:`, `x:`, `y:`, `type:`, `pad_width:`, `pad_height:` | `cw`, `ch`, `cx`, `cy`, `crop.type`, `crop.pad.width`, `crop.pad.height` |
| `clip_path` | `name` | `clipPath` |

```ruby
Sirv::SirvImage.new(url).crop(width: 200, height: 200, type: "face")
```

### Rotation

| Method | Parameters | URL Params |
|---|---|---|
| `rotate` | `degrees` | `rotate` |
| `flip` | — | `flip` |
| `flop` | — | `flop` |

```ruby
Sirv::SirvImage.new(url).rotate(90).flip
```

### Format

| Method | Parameters | URL Params |
|---|---|---|
| `format` | `fmt` | `format` |
| `quality` | `q` | `q` |
| `webp_fallback` | `fmt` | `webp-fallback` |
| `subsampling` | `v` | `subsampling` |
| `png_optimize` | `enabled` (default `true`) | `png.optimize` |
| `gif_lossy` | `level` | `gif.lossy` |

```ruby
Sirv::SirvImage.new(url).format("webp").quality(85)
```

### Color Adjustments

| Method | Parameters | URL Params |
|---|---|---|
| `brightness` | `v` | `brightness` |
| `contrast` | `v` | `contrast` |
| `exposure` | `v` | `exposure` |
| `hue` | `v` | `hue` |
| `saturation` | `v` | `saturation` |
| `lightness` | `v` | `lightness` |
| `shadows` | `v` | `shadows` |
| `highlights` | `v` | `highlights` |
| `grayscale` | — | `grayscale` |
| `color_level` | `black:`, `white:` | `colorlevel.black`, `colorlevel.white` |
| `histogram` | `channel` | `histogram` |

```ruby
Sirv::SirvImage.new(url).brightness(15).contrast(10).grayscale
```

### Color Effects

| Method | Parameters | URL Params |
|---|---|---|
| `colorize` | `color:`, `opacity:` | `colorize.color`, `colorize.opacity` |
| `colortone` | `preset` or `color:`, `level:`, `mode:` | `colortone` or `colortone.color`, `colortone.level`, `colortone.mode` |

```ruby
Sirv::SirvImage.new(url).colorize(color: "ff0000", opacity: 50)
Sirv::SirvImage.new(url).colortone("sepia")
Sirv::SirvImage.new(url).colortone(color: "ff6600", level: 80, mode: "solid")
```

### Effects

| Method | Parameters | URL Params |
|---|---|---|
| `blur` | `v` | `blur` |
| `sharpen` | `v` | `sharpen` |
| `vignette` | `value:`, `color:` | `vignette.value`, `vignette.color` |
| `opacity` | `v` | `opacity` |

```ruby
Sirv::SirvImage.new(url).blur(5).vignette(value: 50, color: "000000")
```

### Text Overlay

Supports multiple layers — each call to `text` adds a new layer.

| Option | URL Param Suffix |
|---|---|
| `size:` | `.size` |
| `font_size:` | `.font.size` |
| `font_family:` | `.font.family` |
| `font_style:` | `.font.style` |
| `font_weight:` | `.font.weight` |
| `color:` | `.color` |
| `opacity:` | `.opacity` |
| `outline_width:` | `.outline.width` |
| `outline_color:` | `.outline.color` |
| `outline_opacity:` | `.outline.opacity` |
| `outline_blur:` | `.outline.blur` |
| `background_color:` | `.background.color` |
| `background_opacity:` | `.background.opacity` |
| `align:` | `.align` |
| `position:` | `.position` |
| `position_x:` | `.position.x` |
| `position_y:` | `.position.y` |
| `position_gravity:` | `.position.gravity` |

```ruby
Sirv::SirvImage.new(url)
  .text("Title", font_size: 48, color: "ffffff", position: "north")
  .text("Subtitle", font_size: 24, color: "cccccc", position: "south")
```

### Watermark

Supports multiple watermarks — each call adds a new layer.

| Option | URL Param Suffix |
|---|---|
| `position:` | `.position` |
| `position_x:` | `.position.x` |
| `position_y:` | `.position.y` |
| `position_gravity:` | `.position.gravity` |
| `scale_width:` | `.scale.width` |
| `scale_height:` | `.scale.height` |
| `scale_option:` | `.scale.option` |
| `rotate:` | `.rotate` |
| `opacity:` | `.opacity` |
| `layer:` | `.layer` |
| `canvas_color:` | `.canvas.color` |
| `canvas_opacity:` | `.canvas.opacity` |
| `canvas_width:` | `.canvas.width` |
| `canvas_height:` | `.canvas.height` |
| `crop_x:` | `.crop.x` |
| `crop_y:` | `.crop.y` |
| `crop_width:` | `.crop.width` |
| `crop_height:` | `.crop.height` |

```ruby
Sirv::SirvImage.new(url)
  .watermark("/logo.png", position: "southeast", opacity: 50)
  .watermark("/badge.png", position: "northwest", opacity: 80)
```

### Canvas

| Parameter | URL Param |
|---|---|
| `width:` | `canvas.width` |
| `height:` | `canvas.height` |
| `color:` | `canvas.color` |
| `position:` | `canvas.position` |
| `opacity:` | `canvas.opacity` |
| `aspect_ratio:` | `canvas.aspect_ratio` |
| `border_width:` | `canvas.border.width` |
| `border_height:` | `canvas.border.height` |
| `border_color:` | `canvas.border.color` |
| `border_opacity:` | `canvas.border.opacity` |

```ruby
Sirv::SirvImage.new(url).canvas(width: 800, height: 600, color: "f0f0f0")
```

### Frame

| Parameter | URL Param |
|---|---|
| `style:` | `frame.style` |
| `color:` | `frame.color` |
| `width:` | `frame.width` |
| `rim_color:` | `frame.rim.color` |
| `rim_width:` | `frame.rim.width` |

```ruby
Sirv::SirvImage.new(url).frame(style: "simple", color: "333333", width: 10)
```

### Other

| Method | Parameters | URL Params |
|---|---|---|
| `page` | `num` | `page` |
| `profile` | `name` | `profile` |

```ruby
Sirv::SirvImage.new(url).page(3)
Sirv::SirvImage.new(url).profile("my-profile")
```

## Running Tests

```sh
cd ruby
bundle install
bundle exec rspec
```

## License

MIT
