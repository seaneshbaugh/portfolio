# frozen_string_literal: true

require 'exifr/jpeg'

module ActiveStorage
  class Analyzer
    class ImageAnalyzer < Analyzer
      private

      def exif_data(image)
        return unless image.type == 'JPEG'

        exif = EXIFR::JPEG.new(image.path).exif

        return unless exif

        exif.to_hash.each_with_object({}) do |(key, value), acc|
          acc[key.to_s] = (value.is_a?(EXIFR::TIFF::Orientation) ? value.to_sym.to_s : value.to_s).strip
        end
      rescue EXIFR::MalformedImage, EXIFR::MalformedJPEG
        nil
      end

      public

      def metadata
        read_image do |image|
          if rotated_image?(image)
            { width: image.height, height: image.width }
          else
            { width: image.width, height: image.height }
          end.merge({ exif: exif_data(image) || {} })
        end
      end
    end
  end
end
