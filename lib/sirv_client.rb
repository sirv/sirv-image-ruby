# frozen_string_literal: true

require "cgi"

module Sirv
  # SDK for building Sirv URLs and HTML tags for images, spins, videos, 3D models, and galleries.
  #
  # @example
  #   sirv = Sirv::SirvClient.new(domain: 'demo.sirv.com', defaults: { q: 80 })
  #   url = sirv.url('/image.jpg', w: 300, format: 'webp')
  #   html = sirv.image('/photo.jpg', alt: 'A photo')
  #
  class SirvClient
    # Create a SirvClient instance.
    #
    # @param domain [String] Sirv domain (e.g. 'demo.sirv.com')
    # @param defaults [Hash] Default query parameters merged into every URL
    # @raise [ArgumentError] if domain is not provided
    def initialize(domain:, defaults: {})
      raise ArgumentError, "domain is required" if domain.nil? || domain.empty?

      @domain = domain.gsub(%r{/+\z}, "")
      @defaults = defaults
    end

    # Build a full Sirv URL.
    #
    # @param path [String] Asset path (e.g. '/image.jpg')
    # @param params [Hash] Transformation parameters (nested hashes are flattened to dot-notation)
    # @return [String]
    def url(path, params = {})
      normalized = path.start_with?("/") ? path : "/#{path}"
      "https://#{@domain}#{normalized}#{build_query(params)}"
    end

    # Generate a srcset string for responsive images.
    #
    # Supports three modes:
    # - Explicit widths: `widths: [320, 640, 960]`
    # - Auto-range: `min_width: 200, max_width: 2000, tolerance: 0.15`
    # - Device pixel ratios: `device_pixel_ratios: [1, 2, 3]` with variable quality
    #
    # @param path [String] Image path
    # @param params [Hash] Transformation parameters
    # @param widths [Array<Integer>, nil] Explicit list of widths
    # @param min_width [Integer, nil] Minimum width for auto-generation
    # @param max_width [Integer, nil] Maximum width for auto-generation
    # @param tolerance [Float] Tolerance for auto-generating widths (0-1)
    # @param device_pixel_ratios [Array<Numeric>, nil] DPR values (e.g. [1, 2, 3])
    # @return [String]
    def src_set(path, params = {}, widths: nil, min_width: nil, max_width: nil, tolerance: 0.15, device_pixel_ratios: nil)
      if widths
        return widths
          .map { |w| "#{url(path, params.merge(w: w))} #{w}w" }
          .join(", ")
      end

      if min_width && max_width
        generated = generate_widths(min_width, max_width, tolerance)
        return generated
          .map { |w| "#{url(path, params.merge(w: w))} #{w}w" }
          .join(", ")
      end

      if device_pixel_ratios
        base_q = params[:q] || params["q"] || @defaults[:q] || @defaults["q"] || 80
        return device_pixel_ratios
          .map do |dpr|
            q = dpr_quality(base_q, dpr)
            dpr_params = params.merge(q: q)
            dpr_params[:w] = params[:w] * dpr if params[:w]
            dpr_params[:h] = params[:h] * dpr if params[:h]
            "#{url(path, dpr_params)} #{dpr}x"
          end
          .join(", ")
      end

      ""
    end

    # Generate an <img> tag for a Sirv image.
    #
    # @param path [String] Image path
    # @param transform [Hash, nil] Transformation parameters for the URL
    # @param viewer [Hash, nil] Viewer options for data-options attribute
    # @param alt [String, nil] Alt text
    # @param class_name [String, nil] Additional CSS class(es)
    # @return [String]
    def image(path, transform: nil, viewer: nil, alt: nil, class_name: nil)
      src = url(path, transform || {})
      cls = class_name ? "Sirv #{class_name}" : "Sirv"
      html = "<img class=\"#{cls}\" data-src=\"#{escape_attr(src)}\""
      html += " alt=\"#{escape_attr(alt)}\"" unless alt.nil?
      html += " data-options=\"#{escape_attr(serialize_viewer_options(viewer))}\"" if viewer
      html += ">"
      html
    end

    # Generate a <div> tag for a Sirv zoom viewer.
    #
    # @param path [String] Image path
    # @param transform [Hash, nil] Transformation parameters
    # @param viewer [Hash, nil] Viewer options
    # @param class_name [String, nil] Additional CSS class(es)
    # @return [String]
    def zoom(path, transform: nil, viewer: nil, class_name: nil)
      viewer_div(path, "zoom", transform: transform, viewer: viewer, class_name: class_name)
    end

    # Generate a <div> tag for a Sirv spin viewer.
    #
    # @param path [String] Path to .spin file
    # @param transform [Hash, nil] Transformation parameters
    # @param viewer [Hash, nil] Viewer options
    # @param class_name [String, nil] Additional CSS class(es)
    # @return [String]
    def spin(path, transform: nil, viewer: nil, class_name: nil)
      viewer_div(path, nil, transform: transform, viewer: viewer, class_name: class_name)
    end

    # Generate a <div> tag for a Sirv video.
    #
    # @param path [String] Video path
    # @param transform [Hash, nil] Transformation parameters
    # @param viewer [Hash, nil] Viewer options
    # @param class_name [String, nil] Additional CSS class(es)
    # @return [String]
    def video(path, transform: nil, viewer: nil, class_name: nil)
      viewer_div(path, nil, transform: transform, viewer: viewer, class_name: class_name)
    end

    # Generate a <div> tag for a Sirv 3D model viewer.
    #
    # @param path [String] Path to .glb file
    # @param transform [Hash, nil] Transformation parameters
    # @param viewer [Hash, nil] Viewer options
    # @param class_name [String, nil] Additional CSS class(es)
    # @return [String]
    def model(path, transform: nil, viewer: nil, class_name: nil)
      viewer_div(path, nil, transform: transform, viewer: viewer, class_name: class_name)
    end

    # Generate a gallery container with multiple assets.
    #
    # @param items [Array<Hash>] Gallery items, each with:
    #   - :src [String] Asset path
    #   - :type [String, nil] Asset type override (e.g. 'zoom', 'spin')
    #   - :transform [Hash, nil] Per-item transformation params
    #   - :viewer [Hash, nil] Per-item viewer options
    # @param viewer [Hash, nil] Gallery-level viewer options
    # @param class_name [String, nil] Additional CSS class(es) for the gallery container
    # @return [String]
    def gallery(items, viewer: nil, class_name: nil)
      cls = class_name ? "Sirv #{class_name}" : "Sirv"
      html = "<div class=\"#{cls}\""
      html += " data-options=\"#{escape_attr(serialize_viewer_options(viewer))}\"" if viewer
      html += ">"

      items.each do |item|
        src = url(item[:src], item[:transform] || {})
        child = "<div data-src=\"#{escape_attr(src)}\""
        child += " data-type=\"#{item[:type]}\"" if item[:type]
        child += " data-options=\"#{escape_attr(serialize_viewer_options(item[:viewer]))}\"" if item[:viewer]
        child += "></div>"
        html += child
      end

      html += "</div>"
      html
    end

    # Generate a <script> tag to load Sirv JS.
    #
    # @param modules [Array<String>, nil] Specific modules to load (e.g. ['spin', 'zoom'])
    # @param async [Boolean] Whether to add async attribute (default: true)
    # @return [String]
    def script_tag(modules: nil, async: true)
      filename = "sirv"
      if modules && !modules.empty?
        filename = "sirv.#{modules.join(".")}"
      end
      html = "<script src=\"https://scripts.sirv.com/sirvjs/v3/#{filename}.js\""
      html += " async" if async
      html += "></script>"
      html
    end

    private

    # Flatten a nested hash into dot-notation key-value pairs.
    #
    # @param obj [Hash]
    # @param prefix [String]
    # @return [Array<Array(String, String)>]
    def flatten_params(obj, prefix = "")
      entries = []
      obj.each do |key, value|
        full_key = prefix.empty? ? key.to_s : "#{prefix}.#{key}"
        if value.is_a?(Hash)
          entries.concat(flatten_params(value, full_key))
        elsif !value.nil?
          entries << [full_key, value.to_s]
        end
      end
      entries
    end

    # Build a query string from merged defaults + params.
    #
    # @param params [Hash]
    # @return [String]
    def build_query(params = {})
      merged = @defaults.merge(params)
      entries = flatten_params(merged)
      return "" if entries.empty?

      "?" + entries.map { |k, v| "#{CGI.escape(k)}=#{CGI.escape(v)}" }.join("&")
    end

    # Calculate quality for a given DPR.
    #
    # @param base_q [Numeric] Base quality at 1x
    # @param dpr [Numeric] Device pixel ratio
    # @return [Integer]
    def dpr_quality(base_q, dpr)
      return base_q if dpr <= 1

      (base_q * (0.75**(dpr - 1))).round
    end

    # Generate widths between min and max using a tolerance step.
    #
    # @param min [Numeric]
    # @param max [Numeric]
    # @param tolerance [Float]
    # @return [Array<Integer>]
    def generate_widths(min, max, tolerance)
      widths = []
      current = min.to_f
      while current < max
        widths << current.round
        current *= 1 + tolerance * 2
      end
      widths << max.round
      widths
    end

    # Serialize viewer options to semicolon-separated format.
    #
    # @param opts [Hash]
    # @return [String]
    def serialize_viewer_options(opts)
      opts.map { |k, v| "#{k}:#{v}" }.join(";")
    end

    # Escape HTML attribute values.
    #
    # @param str [String]
    # @return [String]
    def escape_attr(str)
      str.gsub("&", "&amp;").gsub('"', "&quot;").gsub("<", "&lt;").gsub(">", "&gt;")
    end

    # Internal helper to generate viewer div tags.
    #
    # @param path [String]
    # @param type [String, nil] data-type value (e.g. 'zoom'), or nil to omit
    # @param transform [Hash, nil]
    # @param viewer [Hash, nil]
    # @param class_name [String, nil]
    # @return [String]
    def viewer_div(path, type, transform: nil, viewer: nil, class_name: nil)
      src = url(path, transform || {})
      cls = class_name ? "Sirv #{class_name}" : "Sirv"
      html = "<div class=\"#{cls}\" data-src=\"#{escape_attr(src)}\""
      html += " data-type=\"#{type}\"" if type
      html += " data-options=\"#{escape_attr(serialize_viewer_options(viewer))}\"" if viewer
      html += "></div>"
      html
    end
  end
end
