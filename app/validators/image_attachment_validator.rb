# frozen_string_literal: true

class ImageAttachmentValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.attached?

    record.errors.add(attribute, options[:message] || :no_file_uploaded)

    # value.record.send("#{attribute}_attachment").blob.purge

    # value.purge
  end
end
