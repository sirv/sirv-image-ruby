# frozen_string_literal: true

require_relative "../lib/sirv_client"

RSpec.describe Sirv::SirvClient do
  let(:domain) { "demo.sirv.com" }

  # ---------------------------------------------------------------------------
  # Constructor
  # ---------------------------------------------------------------------------

  describe "constructor" do
    it "requires domain" do
      expect { described_class.new(domain: nil) }.to raise_error(ArgumentError, "domain is required")
      expect { described_class.new(domain: "") }.to raise_error(ArgumentError, "domain is required")
    end

    it "creates instance with domain only" do
      sirv = described_class.new(domain: domain)
      expect(sirv.url("/image.jpg")).to eq("https://demo.sirv.com/image.jpg")
    end

    it "strips trailing slash from domain" do
      sirv = described_class.new(domain: "demo.sirv.com/")
      expect(sirv.url("/image.jpg")).to eq("https://demo.sirv.com/image.jpg")
    end

    it "accepts defaults" do
      sirv = described_class.new(domain: domain, defaults: { q: 80 })
      expect(sirv.url("/image.jpg")).to eq("https://demo.sirv.com/image.jpg?q=80")
    end
  end

  # ---------------------------------------------------------------------------
  # url()
  # ---------------------------------------------------------------------------

  describe "#url" do
    it "builds URL with simple params" do
      sirv = described_class.new(domain: domain)
      url = sirv.url("/image.jpg", w: 300, h: 200, format: "webp")
      expect(url).to eq("https://demo.sirv.com/image.jpg?w=300&h=200&format=webp")
    end

    it "merges defaults with params" do
      sirv = described_class.new(domain: domain, defaults: { q: 80 })
      url = sirv.url("/image.jpg", w: 300, h: 200, format: "webp")
      expect(url).to eq("https://demo.sirv.com/image.jpg?q=80&w=300&h=200&format=webp")
    end

    it "params override defaults" do
      sirv = described_class.new(domain: domain, defaults: { q: 80 })
      url = sirv.url("/image.jpg", q: 90)
      expect(url).to eq("https://demo.sirv.com/image.jpg?q=90")
    end

    it "flattens nested params to dot notation" do
      sirv = described_class.new(domain: domain)
      url = sirv.url("/image.jpg", crop: { type: "face", pad: { width: 10, height: 10 } })
      expect(url).to include("crop.type=face")
      expect(url).to include("crop.pad.width=10")
      expect(url).to include("crop.pad.height=10")
    end

    it "flattens deeply nested params" do
      sirv = described_class.new(domain: domain)
      url = sirv.url("/image.jpg", text: { font: { family: "Arial", size: 24 }, color: "white" })
      expect(url).to include("text.font.family=Arial")
      expect(url).to include("text.font.size=24")
      expect(url).to include("text.color=white")
    end

    it "adds leading slash if missing" do
      sirv = described_class.new(domain: domain)
      expect(sirv.url("image.jpg")).to eq("https://demo.sirv.com/image.jpg")
    end

    it "returns clean URL with no params" do
      sirv = described_class.new(domain: domain)
      expect(sirv.url("/image.jpg")).to eq("https://demo.sirv.com/image.jpg")
    end

    it "encodes special characters" do
      sirv = described_class.new(domain: domain)
      url = sirv.url("/image.jpg", subsampling: "4:2:0")
      expect(url).to include("subsampling=4%3A2%3A0")
    end
  end

  # ---------------------------------------------------------------------------
  # src_set()
  # ---------------------------------------------------------------------------

  describe "#src_set" do
    it "generates srcset with explicit widths" do
      sirv = described_class.new(domain: domain)
      srcset = sirv.src_set("/image.jpg", { format: "webp" }, widths: [320, 640, 960])
      expect(srcset).to include("w=320 320w")
      expect(srcset).to include("w=640 640w")
      expect(srcset).to include("w=960 960w")
      expect(srcset).to include("format=webp")
    end

    it "generates srcset with min_width/max_width/tolerance" do
      sirv = described_class.new(domain: domain)
      srcset = sirv.src_set("/image.jpg", { format: "webp" },
                            min_width: 200, max_width: 2000, tolerance: 0.15)
      entries = srcset.split(", ")
      expect(entries.length).to be > 2
      expect(entries[0]).to include("w=200")
      expect(entries[-1]).to include("w=2000")
    end

    it "generates srcset with device_pixel_ratios" do
      sirv = described_class.new(domain: domain, defaults: { q: 80 })
      srcset = sirv.src_set("/hero.jpg", { w: 600, h: 400 },
                            device_pixel_ratios: [1, 2, 3])
      expect(srcset).to include("1x")
      expect(srcset).to include("2x")
      expect(srcset).to include("3x")
      expect(srcset).to include("q=80")
      expect(srcset).to include("w=1200")
      expect(srcset).to include("w=1800")
    end

    it "uses variable quality for DPR" do
      sirv = described_class.new(domain: domain, defaults: { q: 80 })
      srcset = sirv.src_set("/hero.jpg", { w: 600 },
                            device_pixel_ratios: [1, 2, 3])
      entries = srcset.split(", ")
      # q=80 at 1x, q=60 at 2x, q=45 at 3x (80 * 0.75^(dpr-1))
      expect(entries[0]).to include("q=80")
      expect(entries[1]).to include("q=60")
    end

    it "returns empty string with no options" do
      sirv = described_class.new(domain: domain)
      expect(sirv.src_set("/image.jpg")).to eq("")
    end
  end

  # ---------------------------------------------------------------------------
  # image()
  # ---------------------------------------------------------------------------

  describe "#image" do
    it "generates img tag" do
      sirv = described_class.new(domain: domain)
      html = sirv.image("/tomatoes.jpg", alt: "Fresh tomatoes")
      expect(html).to eq('<img class="Sirv" data-src="https://demo.sirv.com/tomatoes.jpg" alt="Fresh tomatoes">')
    end

    it "includes transform params" do
      sirv = described_class.new(domain: domain)
      html = sirv.image("/photo.jpg", transform: { w: 300, format: "webp" })
      expect(html).to include('data-src="https://demo.sirv.com/photo.jpg?w=300&amp;format=webp"')
    end

    it "includes viewer options" do
      sirv = described_class.new(domain: domain)
      html = sirv.image("/photo.jpg", viewer: { autostart: "visible", threshold: 200 })
      expect(html).to include('data-options="autostart:visible;threshold:200"')
    end

    it "includes custom class_name" do
      sirv = described_class.new(domain: domain)
      html = sirv.image("/photo.jpg", class_name: "hero-image")
      expect(html).to include('class="Sirv hero-image"')
    end

    it "includes empty alt" do
      sirv = described_class.new(domain: domain)
      html = sirv.image("/photo.jpg", alt: "")
      expect(html).to include('alt=""')
    end
  end

  # ---------------------------------------------------------------------------
  # zoom()
  # ---------------------------------------------------------------------------

  describe "#zoom" do
    it "generates div with data-type zoom" do
      sirv = described_class.new(domain: domain)
      html = sirv.zoom("/product.jpg")
      expect(html).to eq('<div class="Sirv" data-src="https://demo.sirv.com/product.jpg" data-type="zoom"></div>')
    end

    it "includes viewer options" do
      sirv = described_class.new(domain: domain)
      html = sirv.zoom("/product.jpg", viewer: { mode: "deep", wheel: false })
      expect(html).to include('data-type="zoom"')
      expect(html).to include('data-options="mode:deep;wheel:false"')
    end
  end

  # ---------------------------------------------------------------------------
  # spin()
  # ---------------------------------------------------------------------------

  describe "#spin" do
    it "generates div without data-type" do
      sirv = described_class.new(domain: domain)
      html = sirv.spin("/product.spin")
      expect(html).to eq('<div class="Sirv" data-src="https://demo.sirv.com/product.spin"></div>')
      expect(html).not_to include("data-type")
    end

    it "includes viewer options" do
      sirv = described_class.new(domain: domain)
      html = sirv.spin("/product.spin", viewer: { autostart: "visible", autospin: "lazy" })
      expect(html).to include('data-options="autostart:visible;autospin:lazy"')
    end
  end

  # ---------------------------------------------------------------------------
  # video()
  # ---------------------------------------------------------------------------

  describe "#video" do
    it "generates div without data-type" do
      sirv = described_class.new(domain: domain)
      html = sirv.video("/clip.mp4")
      expect(html).to eq('<div class="Sirv" data-src="https://demo.sirv.com/clip.mp4"></div>')
    end
  end

  # ---------------------------------------------------------------------------
  # model()
  # ---------------------------------------------------------------------------

  describe "#model" do
    it "generates div without data-type" do
      sirv = described_class.new(domain: domain)
      html = sirv.model("/shoe.glb")
      expect(html).to eq('<div class="Sirv" data-src="https://demo.sirv.com/shoe.glb"></div>')
    end
  end

  # ---------------------------------------------------------------------------
  # gallery()
  # ---------------------------------------------------------------------------

  describe "#gallery" do
    it "generates nested divs" do
      sirv = described_class.new(domain: domain)
      html = sirv.gallery([
        { src: "/product.spin" },
        { src: "/front.jpg", type: "zoom" }
      ])
      expect(html).to include('<div class="Sirv">')
      expect(html).to include('data-src="https://demo.sirv.com/product.spin"')
      expect(html).to include('data-src="https://demo.sirv.com/front.jpg" data-type="zoom"')
      expect(html).to match(%r{</div></div>$})
    end

    it "includes gallery-level viewer options" do
      sirv = described_class.new(domain: domain)
      html = sirv.gallery(
        [{ src: "/image1.jpg" }],
        viewer: { arrows: true, thumbnails: "bottom" }
      )
      expect(html).to include('data-options="arrows:true;thumbnails:bottom"')
    end

    it "includes per-item viewer options" do
      sirv = described_class.new(domain: domain)
      html = sirv.gallery([
        { src: "/product.jpg", type: "zoom", viewer: { mode: "deep" } }
      ])
      expect(html).to include('data-type="zoom"')
      expect(html).to include('data-options="mode:deep"')
    end

    it "includes per-item transforms" do
      sirv = described_class.new(domain: domain)
      html = sirv.gallery([
        { src: "/photo.jpg", transform: { w: 800, format: "webp" } }
      ])
      expect(html).to include("w=800")
      expect(html).to include("format=webp")
    end

    it "includes custom class_name" do
      sirv = described_class.new(domain: domain)
      html = sirv.gallery([{ src: "/img.jpg" }], class_name: "product-gallery")
      expect(html).to include('class="Sirv product-gallery"')
    end
  end

  # ---------------------------------------------------------------------------
  # script_tag()
  # ---------------------------------------------------------------------------

  describe "#script_tag" do
    it "generates script tag with no modules" do
      sirv = described_class.new(domain: domain)
      html = sirv.script_tag
      expect(html).to eq('<script src="https://scripts.sirv.com/sirvjs/v3/sirv.js" async></script>')
    end

    it "generates script tag with modules" do
      sirv = described_class.new(domain: domain)
      html = sirv.script_tag(modules: ["spin", "zoom"])
      expect(html).to eq('<script src="https://scripts.sirv.com/sirvjs/v3/sirv.spin.zoom.js" async></script>')
    end

    it "generates script tag without async" do
      sirv = described_class.new(domain: domain)
      html = sirv.script_tag(async: false)
      expect(html).to eq('<script src="https://scripts.sirv.com/sirvjs/v3/sirv.js"></script>')
    end
  end
end
